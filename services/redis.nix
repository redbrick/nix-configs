{
  users.groups.redis = {};
  users.users.redis.group = "redis";

  # Create a log directory with systemd <3
  systemd.services.redis.serviceConfig.LogsDirectory = "redis";

  services.redis = {
    enable = true;
    port = 0;
    unixSocket = "/run/redis/redis.sock";
    unixSocketPerm = 760;

    # Journal
    logfile = "/var/log/redis/redis.log";
    syslog = false;

    settings = {
      rdbcompression = "yes";
      maxmemory = "2G";
      maxmemory-policy = "allkeys-lru";
    };
  };
} 
