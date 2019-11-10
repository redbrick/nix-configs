{ config, pkgs, ... }:
let
  common = import ../../common/variables.nix;
  vhosts = import ./vhosts.nix { inherit config; };
  adminAddr = "webmaster@${common.tld}";

  # Define a base vhost for all TLDs. This will serve only ACME on port 80
  # Everything else is promoted to HTTPS
  acmeVhost = domain: {
    inherit adminAddr;
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
    inherit adminAddr;
    hostName = common.tld;
    serverAliases = [ "www.${common.tld}" ];
    documentRoot = "${common.webtreeDir}/redbrick/htdocs";
    listen = [{ port = 443; }];
    enableSSL = true;
    extraConfig = ''
      Alias /auth/ "${common.webtreeDir}/redbrick/extras/auth/"
      Alias /cgi-bin/ "${common.webtreeDir}/redbrick/extras/cgi-bin/"
      Alias /cmt/ "${common.webtreeDir}/redbrick/extras/cmt/"
      Alias /includes/ "${common.webtreeDir}/redbrick/extras/includes/"
      Alias /robots.txt "${common.webtreeDir}/redbrick/extras/robots.txt"

      ErrorDocument 400 https://www.redbrick.dcu.ie/404.html
      ErrorDocument 404 /404.html
      ErrorDocument 500 /500.html
      ErrorDocument 502 /500.html
      ErrorDocument 503 /500.html
      ErrorDocument 504 /500.html

      # Redirect rb.dcu.ie/~user => user.rb.dcu.ie
      RedirectMatch 301 "^/~(.*)(/(.*))?$" "https://$1.${common.tld}/$2"
    '';
  };
in {
  imports = [
    ./php-fpm.nix
  ];

  # Enable suexec support
  nixpkgs.overlays = [
    (self: super: {
      apacheHttpd = super.apacheHttpd.overrideAttrs (oldAttrs: {
        patches = [ ./httpd-skip-setuid.patch ];
        configureFlags = [
          "--enable-suexec"
          "--with-suexec-bin=/run/wrappers/bin/suexec"
        ] ++ oldAttrs.configureFlags;
      });
    })
  ];

  # NixOS has strict control over setuid
  security.wrappers.suexec = {
    source = "${pkgs.apacheHttpd.out}/bin/suexec";
    capabilities = "cap_setuid,cap_setgid+pe";
    permissions = "4750";
    owner = "root";
    group = "wwwrun";
  };

  services.httpd = {
    inherit adminAddr;
    enable = true;
    extraModules = [ "suexec" "proxy" "proxy_fcgi" ];
    multiProcessingModule = "event";
    maxClients = 250;
    sslServerKey = "${common.certsDir}/${common.tld}/key.pem";
    sslServerCert = "${common.certsDir}/${common.tld}/fullchain.pem";

    extraConfig = ''
      ProxyRequests off
      ProxyVia Off
      ProxyPreserveHost On

      AddHandler cgi-script .cgi
      AddHandler cgi-script .py
      AddHandler cgi-script .sh
      AddHandler server-parsed .shtml
      AddHandler server-parsed .html

      AddType text/html .shtml

      DirectoryIndex index.html index.cgi index.php index.xhtml index.htm index.py

      Options Includes Indexes SymLinksIfOwnerMatch MultiViews ExecCGI

      <IfModule mod_suexec>
        Suexec On
      </IfModule>
    '';

    virtualHosts = [
      (acmeVhost common.tld)
      redbrickVhost
    ] ++ vhosts;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
