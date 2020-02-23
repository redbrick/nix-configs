{
  services.postgresql = {
    enable = true;
    dataDir = "/var/db/postgres";
  };

  services.prometheus.exporters.postgres = {
    enable = true;
    openFirewall = true;
  };
}
