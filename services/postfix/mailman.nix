{config, lib, ...}:
let
  tld = config.redbrick.tld;
  hyperkittySecret = "/var/secrets/hyperkitty.secret";
in {
  services.mailman = {
    enable = true;
    siteOwner = "postmaster@${tld}";
    webHosts = [ "0.0.0.0" ];
    hyperkittyApiKey = lib.fileContents hyperkittySecret;
  };
  networking.firewall.allowedTCPPorts = [ 80 ];
}
