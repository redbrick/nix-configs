{ pkgs, ... }:
with (import ./shared.nix);
{
  services.httpd.virtualHosts = [
    (vhost {
      user = "wiki";
      group = "redbrick";
      hostName = "paste.${tld}";
      serverAliases = [];
      documentRoot = import ../../packages/privatebin {inherit pkgs;};
      extraConfig = "SetEnv CONFIG_PATH /var/lib/privatebin/conf.php";
    })
  ];
}
