# Manual steps post-deploy:
# cd /var/lib/mailman-web && sudo -u wwwrun mailman-web createsuperuser
{ pkgs, lib, config, ... }:
with (import ./shared.nix { tld = config.redbrick.tld; });
let
  # Values taken from mailman nix module
  staticRoot = "/var/lib/mailman-web-static";
  proxyAddress = "unix:/run/mailman-web.socket|uwsgi://127.0.0.1/";

  vhostConfig = {
    inherit adminAddr;
    onlySSL = true;
    useACMEHost = tld;
    serverAliases = [ "localmail.${tld}" ];
    servedDirs = [ { dir = staticRoot; urlPath = "/static"; } ];
    extraConfig = ''
      <Proxy *>
        Order deny,allow
        Allow from all
      </Proxy>

      ProxyPassMatch ^/static !
      ProxyPass / ${proxyAddress}/
      ProxyPassReverse / ${proxyAddress}/
    '';
  };
in {
  # Serve tries to enable nginx. Force it off.
  services.mailman.serve.enable = true;
  services.nginx.enable = false;

  services.mailman.webUser = config.services.httpd.user;
  services.httpd.virtualHosts."lists.${tld}" = vhostConfig;
}
