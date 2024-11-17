# m1cr0man, 2019
# There are 2 reasons the PHP FPM architecture here is the way it is
# 1. Spinning up a systemd service per user is not feasible
# 2. Spinning up one service for all users produces the error "cannot get uid for user 'username'"
#    for a random pool on each startup
# The solution to both these problems is to group users by first character
# (like webtree) and create up to 36 phpfpm services to cover all users
# The systemd service config is mostly cloned from the standard phpfpm nix module
{ lib, pkgs, ... }:
let
  common = import ../../common/variables.nix;
  allUsers = import ./users.nix;
  phpIni = ./php.ini;
  phpPackage = pkgs.php;

  poolConfig = users: with builtins; pkgs.writeText "phpfpm.conf" (concatStringsSep "\n" ([ ''
      [global]
      error_log = /var/log/phpfpm/error.log
      log_level = debug
      daemonize = false
    '' ] ++ (map (user: ''
      [${replaceStrings ["global" "wwwrun"] ["global_user" "wwwrun_user"] user.uid}]
      listen = /run/phpfpm/${user.uid}.sock
      chdir = ${if ((substring 0 8 user.home) == "/var/lib") then user.home else common.userWebtree user.uid}
      user = ${user.uid}
      group = ${user.gid}
      pm = ondemand
      pm.process_idle_timeout = 1m
      pm.max_children = 5
      listen.owner = wwwrun
      listen.group = wwwrun
    '') users))
  );

  service = name: users: {
    description = "PHP FastCGI Process Manager service for Redbrick user pool ${name}";
    after = [ "network.target" ];
    wantedBy = [ "phpfpm.target" ];
    partOf = [ "phpfpm.target" ];
    serviceConfig = {
      Slice = "phpfpm.slice";
      Type = "notify";
      Restart = "always";
      RestartSec = 10;
      PrivateDevices = true;
      ProtectSystem = "full";
      ProtectHome = true;
      RuntimeDirectoryPreserve = true; # Relevant when multiple processes are running
      RuntimeDirectory = "phpfpm";
      # XXX: We need AF_NETLINK to make the sendmail SUID binary from postfix work
      RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
      ExecStart = "${phpPackage}/bin/php-fpm -y ${poolConfig users} -c ${phpIni}";
      ExecReload = "${pkgs.coreutils}/bin/kill -USR2 $MAINPID";
    };
  };

in {
  systemd.services = with lib; mapAttrs'
    (key: userGroup: nameValuePair ("phpfpm-rbusers-${key}") (service key userGroup))
    (groupBy (user: builtins.substring 0 1 user.uid) allUsers);

  services.phpfpm.pools.wwwrun = with builtins; let
    user = "wwwrun";
  in {
    user = user;
    group = user;
    settings = {
      "listen.owner" = user;
      "listen.group" = user;
      "pm" = "dynamic";
      "pm.start_servers" = 5;
      "pm.max_children" = 75;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
    };
  };
}
