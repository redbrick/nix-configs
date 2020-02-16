{ config, lib, ... }:
let
  dataDir = "/var/lib/loki";
in {

  services.loki = {
    inherit dataDir;
    enable = true;
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_port = 3100;
      };
      ingester = {
        lifecycler= {
          address = "127.0.0.1";
          ring = {
            kvstore = {
              store =  "inmemory";
            };
            replication_factor = 1;
          };
          final_sleep = "0s";
        };
        chunk_idle_period = "5m";
        chunk_retain_period = "30s";
      };
      schema_config = {
        configs = [{
          from = "2018-04-15";
          store = "boltdb";
          object_store = "filesystem";
          schema = "v9";
          index = {
            prefix = "index_";
            period = "168h";
          };
        }];
      };

      storage_config = {
        boltdb = {
          directory = "${dataDir}/index";
        };
        filesystem = {
          directory = "${dataDir}/chunks";
        };
      };

      limits_config = {
        enforce_metric_name = false;
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
      };
      chunk_store_config = {
        max_look_back_period = 0;
      };

      table_manager = {
        chunk_tables_provisioning = {
          inactive_read_throughput = 0;
          inactive_write_throughput = 0;
          provisioned_read_throughput = 0;
          provisioned_write_throughput = 0;
        };
        index_tables_provisioning = {
          inactive_read_throughput = 0;
          inactive_write_throughput = 0;
          provisioned_read_throughput = 0;
          provisioned_write_throughput = 0;
        };
        retention_deletes_enabled = false;
        retention_period = 0;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 3100 ];
}
