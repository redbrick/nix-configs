{ systemd, pkgs, config, lib, ... }:
let
  tld = config.redbrick.tld;
  dataDir = "/var/lib/grafana";
  ldapConfig = ./ldap.toml;
  plugins = import ../../packages/grafanaPlugin {
    inherit pkgs;
    plugins = [
      {
        name = "grafana-polystat-panel";
        version = "1.1.0";
        sha256 = "151cf9vkdf5r6vhgw2a2j2lvlkvi4aynpi6j5m9ck72qgn3q3v4r";
      }
      {
        name = "grafana-piechart-panel";
        version = "1.4.0";
        sha256 = "0xk1ynr05gsd2cmvb52zp2gl8z5qx1h6mbhr80lx6j27rd3q0pxi";
      }
      {
        name = "grafana-clock-panel";
        version = "1.0.3";
        sha256 = "03pb2z9ywzza3my4d58fxw79l7lh3c1vhl09xjyfn4wxp82yic86";
      }
    ];
  };
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
          editable = false;
          url = "http://localhost:3100";
          version = 1;
        }
        {
          name = "Prometheus";
          type = "prometheus";
          editable = false;
          url = "http://localhost:9090";
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
      SERVER_ENABLE_GZIP = "true";
      AUTH_LDAP_ENABLED = "true";
      AUTH_LDAP_CONFIG_FILE = ldapConfig;
      AUTH_LDAP_ALLOW_SIGN_UP = "true";
    };
  };

  systemd.services.grafana.preStart = lib.concatStringsSep "\n"
    (map (plugin: "ln -fs ${plugin.src}/${plugin.name} ${dataDir}/plugins/") plugins);
}
