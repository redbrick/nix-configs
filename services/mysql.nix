{ pkgs, ...}:

let
  backupsDirectory = "/zbackup/backups/mysql";
  maxBackups = 2;
in {
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    # replication = {
    #  role = "master";
    #  serverId = 5;
    #  masterHost = "daedalus.internal";
    #  slaveHost = "daedalus.internal";
    #  masterUser = "replicator";
    #  masterPassword = builtins.readFile "/etc/mysql-replication.secret";
    # };
  };

  systemd.services.mysql-backup = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      path=${backupsDirectory}/backup-$(date +"%F-%T").sql.gz
      ${pkgs.mariadb}/bin/mysqldump --single-transaction --routines --triggers --all-databases | ${pkgs.gzip}/bin/gzip -c >$path
      chmod 400 $path
    '';
  };

  systemd.timers.mysql-backup = {
    wantedBy = [ "multi-user.target" ];
    partOf = [ "mysql-backup.service" ];
    timerConfig.OnCalendar = "daily";
  };

  networking.firewall.allowedTCPPorts = [ 3306 ];
}
