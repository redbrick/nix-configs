{config, lib, pkgs, ...}:
with lib;
let
  package = import ../../packages/anope { inherit pkgs; };
  configFile = ./services.conf;
in {
  users.groups.anope = {};
  users.users.anope = {
    description = "anope daemon user";
    group = "anope";
  };

  systemd.services.anope = {
    description = "A set of IRC Services designed for flexibility and ease of use";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    stopIfChanged = false;

    serviceConfig = {
      ExecStart = "${package}/bin/services --config=${configFile} --confdir=${package}/conf --dbdir=/var/lib/anope --localedir=/usr/lib/anope/locale --logdir=/var/log/anope --modulesdir=${package}/lib/modules --nofork";
      ExecReload = "${pkgs.coreutils}/bin/kill -1 $MAINPID";
      User = "anope";
      Restart = "always";
      RestartSec = "10s";
    };
  };
}
