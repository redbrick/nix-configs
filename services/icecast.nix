{ config, lib, pkgs, ... }:
with lib;
let
  metrics-pkg = import ../../../packages/icecast-exporter { inherit pkgs; };
  port = 8002;
  tld = config.redbrick.tld;
  admin-secret = "/var/secrets/icecast-admin.secret";
  source-secret = "/var/secrets/icecast-source.secret";
  relay-secret = "/var/secrets/icecast-relay.secret";

  # Hard-coded listen address, will be added to the host's
  # internalInterface addresses.
  listenAddress = "192.168.0.5";
in {
  users.users.icecast = {
    description = "Service user for icecast";
    isSystemUser = true;
    shell = "/dev/null";
  };

  networking.interfaces."${config.redbrick.internalInterface}".ipv4.addresses = [{
    address = listenAddress;
    prefixLength = 24;
  }];

  services.icecast = {
    enable = true;
    hostname = "dcufm.${tld}";
    user = "icecast";
    admin = {
      password = "${lib.fileContents admin-secret}";
    };
    listen = {
      inherit port;
      address = listenAddress;
    };
    logDir = "/var/log/icecast/";
    extraConf = ''
    <limits>
        <clients>500</clients>
        <sources>5</sources>
        <threadpool>5</threadpool>
        <queue-size>524288</queue-size>
        <client-timeout>30</client-timeout>
        <header-timeout>15</header-timeout>
        <source-timeout>10</source-timeout>
        <burst-size>65535</burst-size>
    </limits>
    <authentication>
        <source-password>${lib.fileContents source-secret}</source-password>
        <relay-user>relay</relay-user>
        <relay-password>${lib.fileContents relay-secret}</relay-password>
        <admin-user>admin</admin-user>
        <admin-password>${lib.fileContents admin-secret}</admin-password>
    </authentication>
    <directory>
        <yp-url-timeout>15</yp-url-timeout>
        <yp-url>http://dir.xiph.org/cgi-bin/yp-cgi</yp-url>
    </directory>
    <mount>
        <mount-name>/stream128.mp3</mount-name>
        <fallback-mount>/fallback.mp3</fallback-mount>
        <fallback-override>1</fallback-override>
        <fallback-when-full>1</fallback-when-full>
    </mount>
    <fileserve>1</fileserve>
    '';
  };

  systemd.services.icecast-exporter = {
    description = "Icecast Metrics exporter";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${metrics-pkg}/bin/icecast_exporter -log.format='logger:stdout?json=true' -icecast.scrape-uri='http://${listenAddress}:${port}/status-json.xsl'";
      User = "icecast";
      Restart = "always";
      RestartSec = "10s";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8002 9146 ];
}
