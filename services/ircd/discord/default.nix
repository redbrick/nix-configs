{config, lib, pkgs, ...}:
let
  pkg = import ../../../packages/go-discord-irc { inherit pkgs; };
  conf = import ./conf.nix { inherit lib; };
  confFile = pkgs.writeText "discord.yaml" (builtins.toJSON conf);
in {
  systemd.services.go-discord-irc = {
    description = "Discord IRC Bridge Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    stopIfChanged = false;
    environment = let proxy = config.networking.proxy.default; in {
      http_proxy = proxy;
      https_proxy = proxy;
      HTTP_PROXY = proxy;
      HTTPS_PROXY = proxy;
    };
    serviceConfig = {
      ExecStart = "${pkg}/bin/go-discord-irc --config ${confFile}";
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      User = "inspircd";
      Restart = "always";
      RestartSec = "10s";
    };
  };
}
