{ config, pkgs, lib, ... }:
with (import ./shared.nix { tld = config.redbrick.tld; });
let
  vhosts = import ./vhosts.nix { inherit config; };
  errorPages = import ../../packages/httpd-error-pages { inherit pkgs; };

  # Define a base vhost for all TLDs. This will serve only ACME on port 80
  # Everything else is promoted to HTTPS
  acmeVhost = {
    inherit adminAddr;
    serverAliases = ["*"];
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
    documentRoot = "${common.webtreeDir}/redbrick/mkdocs-site/site";
  in {
    inherit adminAddr documentRoot;
    onlySSL = true;
    sslServerKey = "${common.certsDir}/${tld}/key.pem";
    sslServerCert = "${common.certsDir}/${tld}/fullchain.pem";
    extraConfig = ''
      Alias /cgi-bin/ "${common.webtreeDir}/redbrick/extras/cgi-bin/"
      Alias /robots.txt "${common.webtreeDir}/redbrick/extras/robots.txt"

      Header always set Strict-Transport-Security "max-age=63072000"

      # Redirect rb.dcu.ie/~user => user.rb.dcu.ie
      RedirectMatch 301 "^/~([^/]*)/?(.*)$" "https://$1.${tld}/$2"

      # Redirect /cmt to cmtwiki.rb
      RedirectMatch 301 "^/cmt/wiki/?(.*)$" "https://cmtwiki.${tld}/$1"

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

  # Since there's no hostName field inside the vhost attrset,
  # need to map over them and add the ssl keys
  vhostsWithCerts = lib.mapAttrs (hostName: vhost: vhost // {
    useACMEHost = common.certDomain tld hostName;
  }) vhosts;

  virtualHosts = vhostsWithCerts // {
    "${tld}" = redbrickVhost;
    "acme.${tld}" = acmeVhost;
  };

in {
  imports = [
    ./php-fpm.nix
    ./mediawiki.nix
    ./privatebin.nix
    ./mailman.nix
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
    inherit adminAddr virtualHosts;
    enable = true;
    extraModules = [ "suexec" "proxy" "proxy_fcgi" "proxy_uwsgi" "ldap" "authnz_ldap" ];
    mpm = "event";
    maxClients = 250;
    logPerVirtualHost = false;
    extraConfig = ''
      ProxyRequests off
      ProxyVia Off
      ProxyPreserveHost On

      SSLSessionTickets off
      SSLUseStapling On
      SSLStaplingCache "shmcb:/run/httpd/ssl_stapling(32768)"

      Alias /rb_custom_error/ "${errorPages}/"
      ErrorDocument 400 /rb_custom_error/404.html
      ErrorDocument 401 /rb_custom_error/401.html
      ErrorDocument 403 /rb_custom_error/403.html
      ErrorDocument 404 /rb_custom_error/404.html
      ErrorDocument 500 /rb_custom_error/500.html
      ErrorDocument 502 /rb_custom_error/500.html
      ErrorDocument 503 /rb_custom_error/500.html
      ErrorDocument 504 /rb_custom_error/500.html

      <Directory "${errorPages}/" >
        Options Indexes FollowSymLinks IncludesNoExec
        AllowOverride None
        Require all granted
      </Directory>

      AddHandler cgi-script .cgi
      AddHandler cgi-script .sh
      AddHandler server-parsed .shtml
      AddHandler server-parsed .html

      AddType text/html .shtml

      DirectoryIndex index.html index.cgi index.php index.xhtml index.htm index.py

      Options Includes Indexes SymLinksIfOwnerMatch MultiViews ExecCGI

      <IfModule mod_suexec>
        Suexec On
      </IfModule>

      ErrorLogFormat "{ \"app\": \"httpd\", \"level\":\"ERROR\", \"time\":\"%{%Y-%m-%d}tT%{%T}t.%{msec_frac}tZ\", \"function\": \"%-m:%l\" , \"pid\": \"%P\", \"tid\": \"%T\", \"message\": \"%M\", \"referer\": \"%{Referer}i\" }"
      LogFormat "{ \"app\": \"httpd\", \"time\":\"%{%Y-%m-%d}tT%{%T}t.%{msec_frac}tZ\", \"remoteIP\":\"%a\", \"host\":\"%V\", \"request\":\"%U\", \"query\":\"%q\", \"method\":\"%m\", \"status\":\"%>s\", \"userAgent\":\"%{User-agent}i\", \"referer\":\"%{Referer}i\" }" accessJson

      ErrorLog  "| ${pkgs.logger}/bin/logger -thttpd -plocal6.err"
      CustomLog "| ${pkgs.logger}/bin/logger -thttpd -plocal6.notice" accessJson
    '';
  };

  # Needs to be increased because each vhost has a log file
  systemd.services.httpd.serviceConfig.LimitNOFILE = 16384;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
