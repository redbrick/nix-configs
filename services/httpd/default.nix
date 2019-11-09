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

  redbrickVhost = {
    hostName = common.tld;
    serverAliases = [ "www.${common.tld}" ];
    documentRoot = "${common.webtreeDir}/redbrick/htdocs";
    listen = [{ port = 443; }];
    enableSSL = true;
    extraModules = [ "suexec" ];
    extraConfig = ''
      Options Includes Indexes SymLinksIfOwnerMatch MultiViews ExecCGI

      Alias /auth/ "${common.webtreeDir}/redbrick/extras/auth/"
      Alias /cgi-bin/ "${common.webtreeDir}/redbrick/extras/cgi-bin/"
      Alias /cmt/ "${common.webtreeDir}/redbrick/extras/cmt/"
      Alias /includes/ "${common.webtreeDir}/redbrick/extras/includes/"
      Alias /robots.txt "${common.webtreeDir}/redbrick/extras/robots.txt"

      # Redirect rb.dcu.ie/~user => user.rb.dcu.ie
      RedirectMatch 301 "^/~(.*)(/(.*))?$" "https://$1.${common.tld}/$2"
    '';
  };
in {
  imports = [
    ./php-fpm.nix
  ];

  services.httpd = {
    enable = true;
    adminAddr = "admins+httpd@${common.tld}";
    multiProcessingModule = "event";
    maxClients = 250;
    sslServerKey = "${common.certsDir}/${common.tld}/key.pem";
    sslServerCert = "${common.certsDir}/${common.tld}/fullchain.pem";

    user = "root";
    group = "root";

    extraConfig = ''
      ProxyRequests off
      ProxyVia Off
      ProxyPreserveHost On

      AddHandler cgi-script .cgi
      AddHandler cgi-script .py
      AddHandler cgi-script .sh
      AddHandler x-httpd-php .php
      AddHandler x-httpd-php .php3
      AddHandler server-parsed .shtml
      AddHandler server-parsed .html

      AddType text/html .shtml
    '';

    virtualHosts = [
      (acmeVhost common.tld)
      redbrickVhost
    ] ++ vhosts;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
