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
      port 6514
      bind 0.0.0.0
      tag system
      <parse>
        @type syslog
        message_format auto
        with_priority true
      </parse>
    </source>
    <source>
      @type syslog
      port 514
      bind 0.0.0.0
      tag system
      <parse>
        @type syslog
        message_format auto
        with_priority true
      </parse>
    </source>
    <match **>
      @type loki
      url "http://localhost:3100"
      extra_labels {"source":"syslog"}
      flush_interval 10s
      flush_at_shutdown true
      buffer_chunk_limit 1m
      <label>
        fluentd_worker
      </label>
    </match>
    '';
  };

  networking.firewall.allowedTCPPorts = [ 514 6514 ];
}
