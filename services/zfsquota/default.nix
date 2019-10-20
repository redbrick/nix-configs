{ config, pkgs, lib, ... }:
let
  common = import ../../common/variables.nix;
  zfsPackage = if config.boot.zfs.enableUnstable then pkgs.zfsUnstable else pkgs.zfs;
  dataset = config.redbrick.zfsquotaDataset;
  queryPort = 1995;
in {
  imports = [ ./options.nix ];

  networking.firewall.allowedTCPPorts = [ queryPort ];

  systemd.services.zfsquotaquery = {
    description = "Allows users to get their LDAP quota";
    requires = [ "${dataset}.mount" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [ socat zfsPackage ];

    script = ''socat -u tcp-l:${queryPort},fork,reuseaddr system:'
      read USERNAME_RAW
      USERNAME="''${USERNAME_RAW//[^a-zA-Z0-9]/}"
      echo $(zfs get userquota@"$USERNAME" -Ho value ${dataset}) $(zfs get userused@"$USERNAME" -Ho value ${dataset})
      ' &
    '';

    serviceConfig = {
      Restart = "always";
    };
  };

  systemd.services.zfsquota = {
    description = "Sync ZFS quotas with LDAP";
    requires = [ "${dataset}.mount" ];

    path = with pkgs; [ openldap zfsPackage gawk ];

    script = ''
      ldapsearch -h ${common.ldapHost} -p 389 -xLLL -b o=redbrick '(&(objectClass=posixAccount)(quota=*)) uidNumber quota |\
      awk '/^uidNumber:/ { u=$2 } /^quota:/ { q=$2 } u & q { print "userquota@"u"="q; q="";u=""; }' |\
      xargs -I {} zfs set {} ${dataset}
    '';

    serviceConfig = {
      Restart = "no";
      Type = "oneshot";
    };
  };

  systemd.timers.zfsquota = {
    description = "Timer to kick off zfsquota.service every 3 hours";
    wantedBy = [ "multi-user.target" ];

    timerConfig = {
      OnCalendar = "01/3:00:00";
      Unit = "zfsquota.service";
    };
  };
}
