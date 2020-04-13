{config, pkgs, ...}:
let
  common = import ./variables.nix;
  tld = config.redbrick.tld;
in {
  imports = [
    ./options.nix
    ../packages/overlays
  ];

  time.timeZone = "Europe/Dublin";
  i18n.defaultLocale = "en_IE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  # Set sensible kernel parameters
  boot.kernelParams = [
    "boot.shell_on_fail"
    "panic=30" "boot.panic_on_fail" # reboot the machine upon fatal boot issues
  ];

  # Fix mounting of nfs shares before network is up
  systemd.targets.nfs-client.after = [ "network.target" ];
  systemd.targets.nfs-client.requires = [ "network.target" ];

  # Use Redbrick DNS and HTTP proxy
  networking.domain = tld;
  networking.search = [ "internal" tld ];
  networking.nameservers = ["192.168.0.4"];
  networking.timeServers = ["192.168.0.254"];
  networking.proxy.default = "http://proxy.internal:3128/";
  networking.proxy.noProxy = "127.0.0.1,localhost,192.168.0,.internal";

  # Enable rsyslog
  services.rsyslogd.enable = true;
  services.rsyslogd.extraConfig = "*.* @@log.internal:514;RSYSLOG_SyslogProtocol23Format";

  # Enable Node exporter
  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
    enabledCollectors = [
      "systemd"
      "conntrack"
      "cpu"
      "diskstats"
      "entropy"
      "filefd"
      "filesystem"
      "interrupts"
      "loadavg"
      "meminfo"
      "netdev"
      "netstat"
      "stat"
      "time"
      "vmstat"
    ];
  };

  # Enabled Spare cpu cycles to be used for folding@home
  services.foldingathome = {
    enable = true;
    user = "redbrick";
    team = 43166;
    extraArgs = [ "--power" "light" ];
  };

  # Enable LDAP
  users.ldap.enable = true;
  users.ldap.timeLimit = 2;
  users.ldap.server = "ldap://${common.ldapHostIp}/";
  users.ldap.base = "o=redbrick";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim git screen tmux unzip megacli ipmitool smartmontools htop
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable accounting so systemd-cgtop can show IO load
  systemd.enableCgroupAccounting = true;

  # Enable and configure ZFS. It won't affect anything
  # if a machine doesn't use it
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    enableUnstable = true;
    forceImportRoot = true;
    forceImportAll = false;
  };
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 8;
    hourly = 0;
    daily = 7;
    weekly = 0;
    monthly = 1;
  };

  users.ldap.daemon.enable = true;
  # Increasing this limit helps with phpfpm/httpd startup issues
  systemd.services.nscd.serviceConfig.LimitNOFILE = 16384;
  services.nscd.config = ''
    # We basically use nscd as a proxy for forwarding nss requests to appropriate
    # nss modules, as we run nscd with LD_LIBRARY_PATH set to the directory
    # containing all such modules
    # Note that we can not use `enable-cache no` As this will actually cause nscd
    # to just reject the nss requests it receives, which then causes glibc to
    # fallback to trying to handle the request by itself. Which won't work as glibc
    # is not aware of the path in which the nss modules live.  As a workaround, we
    # have `enable-cache yes` with an explicit ttl of 0
    # Redbrick Modification (m1cr0man 16-nov-19): Enable the caching for passwd
    # and group, and set reload-count to 0 to avoid unnecessary refreshes.
    # Changed hosts cache time to 3 minutes from 10
    server-user             nscd

    enable-cache            passwd          yes
    positive-time-to-live   passwd          120
    negative-time-to-live   passwd          120
    reload-count            passwd          0
    shared                  passwd          yes

    enable-cache            group           yes
    positive-time-to-live   group           120
    negative-time-to-live   group           120
    reload-count            group           0
    shared                  group           yes

    enable-cache            netgroup        yes
    positive-time-to-live   netgroup        0
    negative-time-to-live   netgroup        0
    reload-count            netgroup        0
    shared                  netgroup        yes

    enable-cache            hosts           yes
    positive-time-to-live   hosts           180
    negative-time-to-live   hosts           000
    reload-count            hosts           0
    shared                  hosts           yes

    enable-cache            services        yes
    positive-time-to-live   services        0
    negative-time-to-live   services        0
    reload-count            services        0
    shared                  services        yes
  '';
}
