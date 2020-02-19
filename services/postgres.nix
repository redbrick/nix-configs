{
  services.postgresql = {
    enable = true;
    dataDir = "/zroot/postgres";
  };

  services.prometheus.exporters.postgres = {
    enable = true;
    openFirewall = true;
  };
}
