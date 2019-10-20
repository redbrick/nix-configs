{ config, pkgs, lib, ... }:
let
  common = import ../../common/variables.nix;
  zfsPackage = if config.boot.zfs.enableUnstable then pkgs.zfsUnstable else pkgs.zfs;
in {
  imports = [ ./options.nix ];

  systemd.services.zfsquota = {
    description = "Sync ZFS quotas with LDAP";
    requires = [ "${config.redbrick.zfsquotaDataset}.mount" ];

    path = with pkgs; [ openldap zfsPackage gawk ];

    script = ''
      ldapsearch -h ${common.ldapHost} -p 389 -xLLL -b o=redbrick objectClass=posixAccount uidNumber |\
      awk '/^uidNumber/ { print "userquota@"$2"=${config.redbrick.zfsquotaSize}" }' |\
      xargs -I {} zfs set {} ${config.redbrick.zfsquotaDataset}
    '';

    serviceConfig = {
      Restart = "no";
      Type = "oneshot";
    };
  };

  systemd.timers.zfsquota = {
    description = "Timer to kick off zfsquota.service every day at 8am";
    wantedBy = [ "multi-user.target" ];

    timerConfig = {
      OnCalendar = "08:00:00";
      Unit = "zfsquota.service";
    };
  };
}
