{ config, pkgs, ... }:
let
  common = import ../../common/variables.nix;
  zfsPackage = if config.boot.zfs.enableUnstable then pkgs.zfsUnstable else pkgs.zfs;

  quotaScript = pkgs.writeShellScriptBin "zfsquota.sh" ''
    ldapsearch -h ${common.ldapHost} -p 389 -xLLL -b o=redbrick objectClass=posixAccount uidNumber |\
    awk '/^uidNumber/ { print "userquota@"$2"=${config.redbrick.zfsquotaSize}" }' |\
    xargs -I {} zfs set {} ${config.redbrick.zfsquotaDataset}
  '';
in {
  systemd.services.zfsquota = {
    description = "Sync ZFS quotas with LDAP";
    requires = [ "${config.redbrick.zfsquotaDataset}.mount" ];

    environment = {
      PATH = with pkgs; "${openldap}/bin:${zfsPackage}:/bin:${findutils}/bin:${gawk}/bin";
    };

    serviceConfig = {
      ExecStart = "${quotaScript}/bin/zfsquota.sh";
      Restart = "no";
    };
  };

  systemd.timers.zfsquota = {
    description = "Timer to kick off zfsquota.service every day at 8am";
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ quotaScript ];

    timerConfig = {
      OnCalendar = "08:00:00";
      Unit = "zfsquota.service";
    };
  };
}
