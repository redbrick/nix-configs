{ config, pkgs, ... }:
with (import ./shared.nix { tld = config.redbrick.tld; });
let
  user = "wwwrun";
  group = "redbrick";
in {
  services.httpd.virtualHosts."blog.${tld}" = (vhost {
    inherit user group;
    documentRoot = import ../../packages/blog { inherit pkgs; };
  }) // (common.vhostCerts tld);
}
