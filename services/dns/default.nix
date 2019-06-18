{
  services.bind = {
    enable = true;

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
    ];
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
