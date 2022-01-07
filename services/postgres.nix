{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_9_6;
    dataDir = "/var/db/postgres";
  };

  services.prometheus.exporters.postgres = {
    enable = true;
    openFirewall = true;
  };
}
