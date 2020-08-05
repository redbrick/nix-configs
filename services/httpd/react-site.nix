{ config, pkgs, lib, ... }:
with (import ./shared.nix { tld = config.redbrick.tld; });
let
  nodePackages = import ../../packages/node-packages/override.nix { inherit pkgs; };
  react-site = nodePackages.react-site;
  documentRoot = "/var/lib/react-site";
  proxyEnv = with { addr = config.networking.proxy.default; }; pkgs.writeText "proxy-env-vars" ''
    http_proxy=${addr}
    https_proxy=${addr}
    HTTP_PROXY=${addr}
    HTTPS_PROXY=${addr}
  '';
in {
  systemd.services.react-site-build = {
    before = [ "httpd.service" ];
    script = ''
      ln -s react-site-ro/node_modules .
      ln -s react-site-ro/src .
      cp -an react-site-ro/*.js* .
      node_modules/.bin/gatsby build
      chown -R wwwrun:wwwrun public/.
      chmod -R 440 public/.
    '';
    serviceConfig = {
      Type = "oneshot";
      PrivateTmp = true;
      EnvironmentFile = [ "/var/secrets/react-site.env" proxyEnv ];
      BindPaths = "${react-site}/lib/node_modules/Redbrick:/tmp/react-site-ro ${documentRoot}:/tmp/public";
      StateDirectory = "react-site"; # /var/lib/react-site
      WorkingDirectory = "/tmp";
    };
  };

  systemd.timers.react-site-build = {
    wantedBy = [ "timers.target" ];
    partOf = [ "react-site-build.service" ];
    timerConfig.OnCalendar = "daily";
  };

  services.httpd.virtualHosts."${tld}" = {
    inherit adminAddr documentRoot;
    useACMEHost = tld;
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
