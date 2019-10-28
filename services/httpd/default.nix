let
  common = import ../common/variables.nix;
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

    virtualHosts = vhosts ++ [
      (acmeVhost common.tld)
      {
        hostName  = "www.${common.tld}";
        documentRoot = "/storage/webtree/redbrick/htdocs";
        listen = [{ port = 443; }];
        enableSSL = true;
        serverAliases = [ common.tld ];
        extraConfig = ''
          Options Includes Indexes SymLinksIfOwnerMatch MultiViews ExecCGI

          Alias /auth/ "/storage/webtree/redbrick/extras/auth/"
          Alias /cgi-bin/ "/storage/webtree/redbrick/extras/cgi-bin/"
          Alias /cmt/ "/storage/webtree/redbrick/extras/cmt/"
          Alias /includes/ "/storage/webtree/redbrick/extras/includes/"
          Alias /robots.txt "/storage/webtree/redbrick/extras/robots.txt"
          UserDir public_html
          UserDir disabled root
          <Directory /home/*/*/public_html>
            AllowOverride AuthConfig FileInfo Indexes Limit AuthConfig Options=ExecCGI,Includes,IncludesNoExec,Indexes,MultiViews,SymlinksIfOwnerMatch
            Options Indexes SymLinksIfOwnerMatch Includes ExecCGI
          </Directory>
          <Directory /home/*/*/*/public_html>
            AllowOverride AuthConfig FileInfo Indexes Limit AuthConfig Options=ExecCGI,Includes,IncludesNoExec,Indexes,MultiViews,SymlinksIfOwnerMatch
            Options Indexes SymLinksIfOwnerMatch Includes ExecCGI
          </Directory>
        '';
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
