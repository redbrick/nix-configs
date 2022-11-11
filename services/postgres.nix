{pkgs, config, lib, ...}:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_10;
    dataDir = "/var/db/postgres";
    authentication = lib.mkForce ''
    # Generated file; do not edit!
    # TYPE  DATABASE        USER            ADDRESS                 METHOD
    local   all             all                                     trust
    host    all             all             127.0.0.1/32            trust
    host    all             all             ::1/128                 trust
    '';
  };

  services.prometheus.exporters.postgres = {
    enable = true;
    openFirewall = true;
  };
}
