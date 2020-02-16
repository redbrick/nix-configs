{ pkgs, config, lib, ... }:
let
  plugins = import ../packages/fluentd-plugins { inherit pkgs; };
in {

  services.fluentd = {
    enable = true;
    plugins = ["${plugins}/lib/ruby/gems/2.6.0/gems/fluent-plugin-grafana-loki-1.2.7/lib/fluent/plugin"];
    config = ''
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
    '';
  };

  networking.firewall.allowedTCPPorts = [ 5140 ];
}
