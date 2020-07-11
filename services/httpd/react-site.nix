{ config, pkgs, lib, ... }:
with (import ./shared.nix { tld = config.redbrick.tld; });
let
  pkg = import ../../packages/react-site { inherit pkgs; };
  gatsby = import ../../packages/gatsby { inherit pkgs; };
  user = "wwwrun";
  group = "redbrick";
  cacheDir = "/var/tmp/react-site";
  googleApiKey = "/var/secrets/google_api_key.pass";
  documentRoot = "${pkg}/public";
in {
  systemd.tmpfiles.rules = [
    "d '${cacheDir}' 0750 ${user} ${group} - -"
  ];

  systemd.services.react-site-build = {
    wantedBy = [ "multi-user.target" ];
    before = [ "httpd.service" ];
    script = "${gatsby}/bin/gatsby build";
    serviceConfig = {
      Type = "oneshot";
      User = user;
      Group = group;
      PrivateTmp = true;
    };
  };
  systemd.timers.react-site-build = {
    wantedBy = [ "timers.target" ];
    partOf = [ "react-site-build.service" ];
    timerConfig.OnCalendar = "daily";
  };

  services.httpd.virtualHosts."${tld}" = {
    inherit adminAddr documentRoot;
    onlySSL = true;
    sslServerKey = "${common.certsDir}/${tld}/key.pem";
    sslServerCert = "${common.certsDir}/${tld}/fullchain.pem";
    extraConfig = ''
      Alias /cgi-bin/ "${common.webtreeDir}/redbrick/extras/cgi-bin/"
      Alias /robots.txt "${common.webtreeDir}/redbrick/extras/robots.txt"

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
  } // (common.vhostCerts tld);
}
