let
  common = import ../../common/variables.nix;
  vhosts = import ./vhosts.nix;

  # Define a base vhost for all TLDs. This will serve only ACME on port 80
  # Everything else is promoted to HTTPS
  acmeVhost = domain: {
    hostName = domain;
    serverAliases = [ "*.${domain}" ];
    listen = [{ port = 80; }];
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

  redbrickVhost = domain: {
    hostName  = "www.${domain}";
    documentRoot = "${vhosts.webtree}/redbrick/htdocs";
    listen = [{ port = 443; }];
    enableSSL = true;
    extraModules = [ "suexec" ];
    serverAliases = [ domain ];
    extraConfig = ''
      Options Includes Indexes SymLinksIfOwnerMatch MultiViews ExecCGI

      Alias /auth/ "${vhosts.webtree}/redbrick/extras/auth/"
      Alias /cgi-bin/ "${vhosts.webtree}/redbrick/extras/cgi-bin/"
      Alias /cmt/ "${vhosts.webtree}/redbrick/extras/cmt/"
      Alias /includes/ "${vhosts.webtree}/redbrick/extras/includes/"
      Alias /robots.txt "${vhosts.webtree}/redbrick/extras/robots.txt"

      # Redirect rb.dcu.ie/~user => user.rb.dcu.ie
      RedirectMatch 301 "^/~(.*)(/(.*))?$" "https://$1.${domain}/$2"
    '';
  };
in {

  services.httpd = {
    enable = true;
    adminAddr = "admins+httpd@${common.tld}";
    multiProcessingModule = "event";
    maxClients = 250;
    sslServerKey = "${common.certsDir}/${common.tld}/key.pem";
    sslServerCert = "${common.certsDir}/${common.tld}/fullchain.pem";

    extraConfig = ''
      ProxyRequests off
      ProxyVia Off
      ProxyPreserveHost On
    '';

    virtualHosts = [
      (acmeVhost common.tld)
      (redbrickVhost common.tld)
    ] ++ vhosts;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
