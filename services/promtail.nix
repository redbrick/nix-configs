{ config, lib, pkgs, ... }:

let
  prettyJSON = conf:
    pkgs.runCommand "promtail-config.json" { } ''
      echo '${builtins.toJSON conf}' | ${pkgs.jq}/bin/jq 'del(._module)' > $out
    '';
  dataDir = "/var/lib/promtail";
  syslog = {
    job_name = "syslog";
    syslog = {
      listen_address = "0.0.0.0:514";
      idle_timeout = "60s";
      label_structured_data = true;
      labels = {
        job = "syslog";
      };
    };
    relabel_configs = [
      {
        source_labels = [ "__syslog_message_hostname" ];
        target_label = "host";
      }
      {
        source_labels = [ "__syslog_connection_ip_address" ];
        target_label = "ip";
      }
      {
        source_labels = ["__syslog_message_app_name"];
        target_label = "app";
      }
      {
        source_labels = ["__syslog_message_severity"];
        target_label = "level";
      }
    ];
  };
  journal = {
    job_name = "journal";
    journal = {
      max_age= "12h";
      labels = {
        job = "systemd-journal";
      };
    };
    relabel_configs = [
      {
        source_labels = [ "__journal__systemd_unit" ];
        target_label = "unit";
      }
      {
        source_labels = [ "__journal__hostname" ];
        target_label = "host";
      }
      {
        source_labels = ["__journal_syslog_identifier"];
        target_label = "service";
      }
      {
        source_labels = ["__journal_errno"];
        target_label = "severity";
      }
      {
        source_labels = ["__journal_priority"];
        target_label = "level";
      }
      {
        source_labels = ["__journal__UID"];
        target_label = "uid";
      }
      {
        source_labels = ["__journal__GID"];
        target_label = "gid";
      }
    ];
  };
  configuration = {
    server = {
      http_listen_port = 9080;
      grpc_listen_port = 0;
    };
    clients = [{
      url = "http://log.internal:3100/loki/api/v1/push";
    }];
    scrape_configs = [ syslog ];
  };
in {
  systemd.services.promtail = {
    description = "Promtail Service Daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.grafana-loki}/bin/promtail -config.file=${prettyJSON configuration} -positions.file=${dataDir}/position.yaml";
      Restart = "always";
      WorkingDirectory = dataDir;
      StateDirectory = "promtail";
    };
  };

  networking.firewall.allowedTCPPorts = [ 514 ];
}
