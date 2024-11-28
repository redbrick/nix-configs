{
  users.groups.redis = { };
  users.users.redis = {
    group = "redis";
    isSystemUser = true;
  };

  # Create a log directory with systemd <3
  systemd.services.redis.serviceConfig.LogsDirectory = "redis";

  services.redis.servers.redis = {
    enable = true;
    port = 0;
    unixSocket = "/run/redis/redis.sock";
    unixSocketPerm = 0760;

    # Journal
    # logfile = "/var/log/redis/redis.log";
    logfile = "/dev/null";
    syslog = false;

    settings = {
      rdbcompression = "yes";
      maxmemory = "2G";
      maxmemory-policy = "allkeys-lru";
    };
  };
}
