let
  common = import ../common/variables.nix;

  # Define common settings for all ACME cert configurations
  acmeCert = {
    email = "admins+acme@${common.tld}";
    webroot = common.webrootDir;
    postRun = "systemctl reload httpd.service";
  };

  # Define a base vhost for all TLDs. This will serve only ACME on port 80
  # Everything else is promoted to HTTPS
  acmeVhost = domain: {
      hostName = domain;
      serverAliases = [ "*.${domain}" ];
      servedDirs = [{
        urlPath = "/.well-known/acme-challenge";
        dir = "${common.webrootDir}/.well-known/acme-challenge";
      }];

      extraConfig = ''
        RewriteEngine On
        RewriteCond %{HTTPS} off
        RewriteCond %{REQUEST_URI} !^/\.well-known/.*$ [NC]
        RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301]
      '';
    };
in {

  # Acme will automatically create the certsDir and webrootDir
  security.acme.directory = common.certsDir;
  security.acme.certs = {
    "${common.tld}" = acmeCert;
  };

  services.httpd = {
    enable = true;
    multiProcessingModule = "event";
    maxClients = 50;
    sslServerKey = "${common.certsDir}/${common.tld}/key.pem";
    sslServerCert = "${common.certsDir}/${common.tld}/fullchain.pem";

    extraConfig = ''
      ProxyPreserveHost On
    '';

    virtualHosts = [
      (acmeVhost common.tld)
    ];

    adminAddr = "admins+httpd@${common.tld}";
    hostName = "localhost";

    # Only acme certs are accessible via port 80,
    # everything else is explicitly upgraded to https
    listen = [{ port = 80; }];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
