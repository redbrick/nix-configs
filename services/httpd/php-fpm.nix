{ lib, ... }:
let
  common = import ../../common/variables.nix;
  users = import ./users.nix;

  extraPools = with builtins; concatStringsSep "\n" (map (user: ''
    [${replaceStrings ["global" "sharedfpm"] ["global_user" "sharedfpm_user"] user.uid}]
    listen = /run/phpfpm/${user.uid}.sock
    listen.owner = wwwrun
    listen.group = wwwrun
    chdir = ${common.userWebtree user.uid}
    user = ${user.uid}
    group = ${user.gid}
    pm = ondemand
    pm.process_idle_timeout = 1m
    pm.max_children = 5
  '') (lib.take 10 users));
in {
  services.phpfpm.pools.sharedfpm = with builtins; {
    user = "wwwrun";
    group = "wwwrun";
    settings = {
      "pm" = "dynamic";
      "pm.start_servers" = 10;
      "pm.max_children" = 75;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 10;
    };
    extraConfig = extraPools;
  };
}
