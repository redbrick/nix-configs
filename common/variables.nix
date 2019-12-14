rec {
  tld = "redbricktest.ml";

  certsDir = "/var/lib/acme";
  webrootDir = "/var/lib/acme/.webroot";
  webtreeDir = "/storage/webtree";
  homesDir = "/storage/home";

  userWebtree = uid: "${webtreeDir}/${builtins.substring 0 1 uid}/${uid}";

  dovecotHost = "192.168.0.135";
  dovecotSaslPort = 3659;
  dovecotLmtpPort = 24;

  # Hard coded otherwise NSCD will crash systems during boot if network is down
  # 50 = daedalus
  ldapHost = "192.168.0.50";

  bondConfig = interfaces: address: {
    bonds.bond0 = {
      inherit interfaces;
      driverOptions = {
        mode = "802.3ad";
        ad_select = "count";
        lacp_rate = "slow";
        miimon = "100";
        xmit_hash_policy = "layer3+4";
      };
    };

    vlans.internal = {
      id = 3;
      interface = "bond0";
    };

    interfaces.bond0.useDHCP = false;
    interfaces.internal.ipv4.addresses = [{
      inherit address;
      prefixLength = 24;
    }];
  };

  managementConfig = address: {
    vlans.management = {
      id = 4;
      interface = "bond0";
    };

    interfaces.management.ipv4.addresses = [{
      inherit address;
      prefixLength = 24;
    }];
  };

  zfsMountConfig = device: {
    inherit device;
    fsType = "zfs";
    options = [ "nofail" ];
  };
}
