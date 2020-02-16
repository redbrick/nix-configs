{ config, lib, ... }:
let
  tld = config.redbrick.tld;
  dataDir = "/var/lib/grafana";
  ldapConfig = ./ldap.toml;
in {

  services.grafana = {
    inherit dataDir;
    enable   = true;
    port     = 3001;
    domain   = "graphs.${tld}/";
    rootUrl =  "https://graphs.${tld}/";
    protocol = "http";

    security = {
      adminUser = "rbAdmin";
      adminPasswordFile = "/var/secrets/grafana_admin.secret";
    };

    provision = {
      enable = true;
      datasources = [
        {
          name = "InfluxDB";
          type = "influxdb";
          access = "proxy";
          isDefault = true;
          editable = false;
          url = "http://zeus.internal:8086";
          version = 1;
          jsonData = {
            timeInterval = "15s";
          };
        }
        {
          name = "Loki";
          type = "loki";
          isDefault = false;
          editable = false;
          url = "http://localhost:3100";
          version = 1;
        }
        {
          name = "Prometheus";
          type = "prometheus";
          isDefault = false;
          editable = false;
          url = "http://zeus.internal:9090";
          version = 1;
          jsonData = {
            scrapeInterval = "15s";
          };
        }
      ];
    };

    database = {
      type = "postgres";
      host = "localhost";
      name = "grafana";
      user = "grafana";
      passwordFile = "/var/secrets/grafana.secret";
    };

    extraOptions = {
      server_enable_gzip = "true";
      auth_ldap_enabled = "true";
      auth_ldap_config_file = ldapConfig;
      auth_ldap_allow_sign_up = "false";
    };
  };
}
