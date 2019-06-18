let
  common = import ./variables.nix;
in {
  time.timeZone = "Europe/Dublin";
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "uk";
    defaultLocale = "en_IE.UTF-8";
  };

  # Use Redbrick DNS and HTTP proxy
  networking.domain = common.tld;
  networking.nameservers = ["192.168.0.4"];
  networking.proxy.default = "http://proxy.internal:3128/";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal";

  # Enable rsyslog
  services.rsyslogd.enable = true;
  services.rsyslogd.extraConfig = "*.* @log.internal:6514;RSYSLOG_SyslogProtocol23Format";
}
