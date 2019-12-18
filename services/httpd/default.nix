{ config, pkgs, ... }:
let
  common = import ../../common/variables.nix;
  vhosts = import ./vhosts.nix { inherit config; };
  errorPages = import ../../packages/httpd-error-pages { inherit pkgs };
  adminAddr = "webmaster@${common.tld}";

  # Define a base vhost for all TLDs. This will serve only ACME on port 80
  # Everything else is promoted to HTTPS
  acmeVhost = {
    inherit adminAddr;
    hostName = common.tld;
    serverAliases = ["*"];
    listen = [{ port = 80; }];
    documentRoot = common.webtreeCertsDir;

    extraConfig = ''
      RewriteEngine On
      RewriteCond %{HTTPS} off
      RewriteCond %{REQUEST_URI} !^/\.well-known/ [NC]
      RewriteCond %{REQUEST_URI} !^/server-status [NC]
      RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301]
    '';
  };

  redbrickVhost = let
    documentRoot = "${common.webtreeDir}/redbrick/htdocs";
  in {
    inherit adminAddr documentRoot;
    hostName = common.tld;
    listen = [{ port = 443; }];
    enableSSL = true;
    extraConfig = ''
      Alias /cgi-bin/ "${common.webtreeDir}/redbrick/extras/cgi-bin/"
      Alias /robots.txt "${common.webtreeDir}/redbrick/extras/robots.txt"

      # Redirect rb.dcu.ie/~user => user.rb.dcu.ie
      RedirectMatch 301 "^/~(.*)(/(.*))?$" "https://$1.${common.tld}/$2"

      # Redirect /cmt to cmtwiki.rb
      RedirectMatch 301 "^/cmt/wiki(/(.*))?$" "https://cmtwiki.${common.tld}/$1"

      <Directory ${documentRoot}>
        RewriteEngine on
        # Don't rewrite files or directories
        RewriteCond %{REQUEST_FILENAME} -f [OR]
        RewriteCond %{REQUEST_FILENAME} -d
        RewriteRule ^ - [L]
        # Rewrite everything else to index.html to allow html5 state links
        RewriteRule ^ index.html [L]
      </Directory>
    '';
  };
in {
  imports = [
    ./php-fpm.nix
    ./mediawiki.nix
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
    extraModules = [ "suexec" "proxy" "proxy_fcgi" "ldap" "authnz_ldap" ];
    multiProcessingModule = "event";
    maxClients = 250;
    sslServerKey = "${common.certsDir}/${common.tld}/key.pem";
    sslServerCert = "${common.certsDir}/${common.tld}/fullchain.pem";

    extraConfig = ''
      ProxyRequests off
      ProxyVia Off
      ProxyPreserveHost On

      Alias /rb_custom_error/ "${errorPages}"
      ErrorDocument 400 /rb_custom_error/404.html
      ErrorDocument 401 /rb_custom_error/401.html
      ErrorDocument 403 /rb_custom_error/403.html
      ErrorDocument 404 /rb_custom_error/404.html
      ErrorDocument 500 /rb_custom_error/500.html
      ErrorDocument 502 /rb_custom_error/500.html
      ErrorDocument 503 /rb_custom_error/500.html
      ErrorDocument 504 /rb_custom_error/500.html

      <Directory "${errorPages}">
        Require all granted
      </Directory>

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
      acmeVhost
      redbrickVhost
    ] ++ vhosts;
  };

  # Once a week, reload httpd to refresh the certificates
  systemd.services.httpd-reload = {
    description = "Reload HTTPD + load new certs";
    requires = [ "httpd.service" ];
    serviceConfig = {
      Type = "oneshot";
      SuccessExitStatus = [ "0" "1" ];
      PermissionsStartOnly = true;
    };
    script = "systemctl reload httpd";
  };

  systemd.timers.httpd-reload = {
    description = "Reload HTTPD at 5am every Saturday to update certs";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Sat *-*-* 05:00:00";
      Unit = "httpd-reload.service";
      Persistent = "yes";
      AccuracySec = "5m";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
