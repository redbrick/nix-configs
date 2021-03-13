{config, pkgs, ...}:
let
  common = import ./variables.nix;
  tld = config.redbrick.tld;
in {
  imports = [
    ./options.nix
    ./ldap.nix
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
  networking.extraHosts = ''
  192.168.0.156 irc.redbrick.dcu.ie
  192.168.0.156 bitlbee.redbrick.dcu.ie
  192.168.0.158 mail.redbrick.dcu.ie
  '';

  # Enable rsyslog
  services.rsyslogd.enable = true;
  services.rsyslogd.extraConfig = "*.* @@log.internal:514;RSYSLOG_SyslogProtocol23Format";

  # Enable Node exporter
  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
    # This is a temporary fix for an upstream bug. Try removing it and rebuilding config
    # whenever you can.
    firewallFilter = "-p tcp -m tcp --dport 9100";
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

  # Add Root CA for Squid proxy
  security.pki.certificateFiles = [ ./proxycert.pem ];

  # Ensure curl loads the certs so it can connect to proxy
  environment.variables.NIX_CURL_FLAGS = let
    cafile = config.environment.etc."ssl/certs/ca-certificates.crt".source;
  in "--proxy-cacert ${cafile} --cacert ${cafile}";
}
