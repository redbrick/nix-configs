rec {
  certsDir = "/var/lib/acme";
  webtreeCertsDir = "${certsDir}/.webroot";
  webtreeDir = "/storage/webtree";
  homesDir = "/storage/home";

  # This maps some domains to other domains
  # usually due to broken DNS entries
  # Allows certs to be correctly generated
  brokenDomains = {
    "djbdns.now.ie" = "djbdns.now.ie";
    "romana.now.ie" = "djbdns.now.ie";
    "www.luxgaa.lu" = "www.luxgaa.lu";
    "www.iahpc.ie" = "www.iahpc.ie";
    "techweek.dcu.ie" = "techweek.dcu.ie";
  };

  userWebtree = uid: "${webtreeDir}/${builtins.substring 0 1 uid}/${uid}";
  splitDomain = domain: builtins.filter (x: x != []) (builtins.split "\\." domain);

  domainTld = domain: with builtins; let
    splitName = splitDomain domain;
    len = length splitName;
  in
    brokenDomains.${domain} or "${(elemAt splitName (len - 2))}.${(elemAt splitName (len - 1))}";

  # Used in apache and certs config to map virtualHost hostNames to a cert
  certDomain = tld: hostName: let
    theirTld = domainTld hostName;
    isOurTld = ((builtins.match ".*\\.${tld}" hostName) != null);
  in if isOurTld then tld else theirTld;

  dovecotHost = "192.168.0.135";
  dovecotSaslPort = 3659;
  dovecotLmtpPort = 24;

  # Hard coded otherwise NSCD will crash systems during boot if network is down
  # 50 = daedalus
  ldapHostIp = "192.168.0.50";
  ldapHost = "ldap.internal";

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
