{config, lib, pkgs, ...}:
with lib;
let
  package = import ../../packages/anope { inherit pkgs; };
  configFile = ./conf;
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
      ExecStart = "${package}/bin/services --confdir=${configFile} --config=services.conf --dbdir=${dataDir} --localedir=/usr/lib/anope/locale --logdir=${dataDir} --modulesdir=${package}/lib/ --nofork";
      ExecReload = "${pkgs.coreutils}/bin/kill -1 $MAINPID";
      User = "anope";
      Restart = "always";
      RestartSec = "10s";
    };
  };
}
