{config, pkgs, ...}:
let
  common = import ./variables.nix;
in {
  time.timeZone = "Europe/Dublin";
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "uk";
    defaultLocale = "en_IE.UTF-8";
  };

  # Set sensible kernel parameters
  boot.kernelParams = [
    "boot.shell_on_fail"
    "panic=30" "boot.panic_on_fail" # reboot the machine upon fatal boot issues
  ];

  # Use Redbrick DNS and HTTP proxy
  networking.domain = common.tld;
  networking.search = [ "internal" common.tld ];
  networking.nameservers = ["192.168.0.4"];
  networking.proxy.default = "http://proxy.internal:3128/";
  networking.proxy.noProxy = "127.0.0.1,localhost,*.internal";

  # Enable rsyslog
  services.rsyslogd.enable = true;
  services.rsyslogd.extraConfig = "*.* @log.internal:6514;RSYSLOG_SyslogProtocol23Format";

  # Enable LDAP
  users.ldap.enable = true;
  users.ldap.timeLimit = 2;
  users.ldap.server = "ldap://${common.ldapHost}/";
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
    forceImportRoot = false;
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
}
