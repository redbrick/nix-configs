{ config, lib, pkgs, ... }:
with lib;
let
  tld = config.redbrick.tld;
  admin-secret = "/var/secrets/icecast-admin.secret";
  source-secret = "/var/secrets/icecast-source.secret";
  relay-secret = "/var/secrets/icecast-relay.secret";
in {
  users.users.icecast = {
    description = "Service user for icecast";
    isSystemUser = true;
    group = "icecast";
    shell = "/dev/null";
    home = "/dev/null";
  };

  services.icecast = {
    enable = true;
    hostname = "localhost";
    user = "icecast";
    admin = {
      password = "${lib.fileContents admin-secret}";
    };
    listen = {
      port = 8002;
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
  networking.firewall.allowedTCPPorts = [ 8002 ];
}
