{ lib, ... }:
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
        file = "";
        masters = [ "192.168.0.4" ];
        master = false;
        name = "internal";
      }
    ];
  };

  # Fix issues where services can't resolve their targets
  systemd.services.nscd.requires = [ "network-online.target" ];
  systemd.services.nscd.after = [ "network-online.target" ];
  systemd.services.resolvconf.requires = [ "network-online.target" ];
  systemd.services.resolvconf.after = [ "network-online.target" ];

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
