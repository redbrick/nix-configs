{ pkgs, config, lib, ... }:
with config.redbrick.rbbackup;
let
  # Quote and join paths for arguments to rsync
  sourcePaths = lib.concatStringsSep " " (builtins.map
    (srcPath: "'${srcPath}'")
    sources);

in lib.mkIf (sources != []) {
  systemd.services.redbrick-backup = {
    aliases = [ "rbbackup.service" "redbrick-backups.service" ];
    description = "Redbrick backup script. Copies data to ${destination}";
    wants = [ "multi-user.target" ];
    requires = [ "local-fs.target" "network-online.target" ];
    path = with pkgs; [ rsync openssh ] ++ extraPackages;
    script = ''
      set -euxo pipefail
      echo "Backup starting"
      rsync -a --progress --delete ${sourcePaths} ${destination}
      echo "Backup successful"
    '';
    preStart = commands;
    postStop = ''
      rm -rf $CACHE_DIRECTORY
    '';
    serviceConfig = {
      Type = "oneshot";
      CacheDirectory = "redbrick-backups";
      WorkingDirectory = "/var/cache/redbrick-backups";
      UMask = 0077;
    };
  };

  systemd.timers.redbrick-backup = {
    description = "Start Redbrick backup script";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      RandomizedDelaySec = 60 * 30;
    };
  };
}
