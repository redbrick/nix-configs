{ config, lib, ... }:
let
in {

  services.fluentd = {
    enable = true;
    plugins= ["fluent-plugin-grafana-loki"];
    config = """
    <source>
      @type syslog
      port 5140
      bind 0.0.0.0
      tag system
    </source>
    <match **>
      @type loki
      url "http://localhost:3100"
      flush_interval 10s
      flush_at_shutdown true
      buffer_chunk_limit 1m
    </match>
    """;
  };

  networking.firewall.allowedTCPPorts = [ 5140 ];
}
