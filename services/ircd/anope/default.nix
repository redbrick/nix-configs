{config, lib, pkgs, ...}:
with lib;
let
  pkg = import ../../../packages/anope { inherit pkgs; };
  configDir = ./confs;
  configFile = "services.conf";
  dataDir = "/var/lib/anope";
in {
  users.groups.anope = {};
  users.users.anope = {
    description = "anope daemon user";
    group = "anope";
    home = dataDir;
    createHome = true;
    isSystemUser = true;
  };

  systemd.services.anope = {
    description = "A set of IRC Services designed for flexibility and ease of use";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    stopIfChanged = false;

    serviceConfig = {
      ExecStart = "${pkg}/bin/services --confdir=${configDir} --config=${configFile} --dbdir=${dataDir} --localedir=${pkg}/lib/anope/locale --logdir=${dataDir} --modulesdir=${pkg}/lib/ --nofork";
      ExecReload = "${pkgs.coreutils}/bin/kill -1 $MAINPID";
      User = "anope";
      StateDirectory = "anope";
      Restart = "always";
      RestartSec = "10s";
    };
  };
}
