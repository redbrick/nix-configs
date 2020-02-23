{ config, lib, ... }:
let
  tld = config.redbrick.tld;
  # We Should be able to generate this
  nodes = [
    "zeus"
    "daedalus"
    "icarus"
    "hardcase"
    "m1cr0man"
    "butlerxvm"
  ];
  globalConfig = {
    scrape_interval = "15s";
    evaluation_interval = "15s";
  };
in {
  services.prometheus = {
    inherit globalConfig;
    enable = true;
    webExternalUrl = "https://prometheus.${tld}";
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [{ targets = ["localhost:9090"]; }];
      }
      {
        job_name = "promtail";
        static_configs = [{ targets = ["log.internal:9080"]; }];
      }
      {
        job_name = "loki";
        static_configs = [{ targets = ["log.internal:3100"]; }];
      }
      {
        job_name = "postgres";
        static_configs = [{ targets = ["localhost:9187"]; }];
      }
      {
        job_name = "traefik";
        static_configs = [{ targets = ["zeus.internal:8080"]; }];
      }
      {
        job_name = "grafana";
        static_configs = [{ targets = ["localhost:3001"]; }];
      }
      {
        job_name = "gitea";
        static_configs = [{ targets = ["localhost:3000"]; }];
      }
      {
        job_name = "bind";
        static_configs = [{ targets = ["m1cr0man.internal:9119"]; }];
      }
      {
        job_name = "collectd";
        static_configs = [{ targets = ["zeus.internal:9103"]; }];
      }
      {
        # Only to be used with docker
        job_name = "cadvisor";
        static_configs = [{ targets = ["zeus.internal:8081"]; }];
      }
      {
        job_name = "node-exporter";
        static_configs = [{
          targets = (map (node: "${node}.internal:9100") nodes);
        }];
      }
    ];
  };
}
