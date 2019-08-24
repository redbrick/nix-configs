{
  services.bind = {
    enable = true;

    cacheNetworks = [
      "127.0.0.0/24"
      "192.168.0.0/24"
      "192.168.1.0/24"
      "136.206.15.0/24"
      "136.206.16.0/24"
    ];

    zones = [
      {
        # Not using common.tld here becaue we actually want to configure
        # a specific domain
        file = ./redbricktest.ml;
        master = true;
        name = "redbricktest.ml";
      }
      {
        file = ./redbricktest.ml.rr;
        master = true;
        name = "15.206.136.in-addr.arpa";
      }
      {
        masters = [ "192.168.0.4" ];
        master = false;
        name = "internal";
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
