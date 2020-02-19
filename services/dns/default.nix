# Requires tsig-keygen dnsupdate.${tld} > /var/secrets/dnskeys.conf
# chown named:root chmod 400
{ config, lib, ... }:
let
  tld = config.redbrick.tld;

  keysPath = "/var/secrets/dnskeys.conf";
  keyName = "dnsupdate.${tld}.";
  zonePath = "/var/db/bind";
in {
  # Enable eddsa support
  nixpkgs.overlays = [
    (self: super: {
      bind = super.bind.overrideAttrs (oldAttrs: {
        configureFlags = lib.remove "--without-eddsa" oldAttrs.configureFlags;
      });
    })
  ];

  services.bind = {
    enable = true;

    cacheNetworks = [
      "127.0.0.0/24"
      "192.168.0.0/23"
      "136.206.15.0/24"
      "136.206.16.0/24"
    ];

    extraConfig = ''
      include "${keysPath}";
    '';

    zones = [
      {
        # Not using tld here becaue we actually want to configure
        # a specific domain
        file = "${zonePath}/redbricktest.ml";
        master = true;
        name = "redbricktest.ml";
        extraConfig = "allow-update { key ${keyName}; };";
      }
      {
        file = "${zonePath}/redbricktest.ml.rr";
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

  # export metrics
  services.prometheus.exporters.bind = {
    enable = true;
    openFirewall = true;
  };
}
