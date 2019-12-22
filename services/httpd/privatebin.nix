{ pkgs, ... }:
with (import ./shared.nix);
let
  user = "paste";
  group = "redbrick";
in {
  services.httpd.virtualHosts = [
    (vhost {
      inherit user group;
      hostName = "paste.${tld}";
      serverAliases = [];
      documentRoot = import ../../packages/privatebin {inherit pkgs;};
      extraConfig = "SetEnv CONFIG_PATH ${./conf.php}";
    })
  ];
  systemd.tmpfiles.rules = [
    "d '/var/lib/privatebin' 0750 ${user} ${group} - -"
  ];
}
