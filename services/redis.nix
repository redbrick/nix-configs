{
  users.groups.redis = {};
  users.users.redis.group = "redis";

  # Create a log directory with systemd <3
  systemd.services.redis.serviceConfig.LogsDirectory = "redis";

  services.redis = {
    enable = true;
    port = 0;
    unixSocket = "/run/redis/redis.sock";

    # Journal
    logfile = "/var/log/redis/redis.log";
    syslog = false;

    extraConfig = ''
      rdbcompression yes
      maxmemory 2G
      maxmemory-policy allkeys-lru
      unixsocketperm 660
    '';
  };
}
