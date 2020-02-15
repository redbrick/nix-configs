{config, lib, ...}:
let
  tld = config.redbrick.tld;
  hyperkittySecret = "/var/secrets/hyperkitty.secret";
in {
  services.mailman = {
    enable = true;
    siteOwner = "postmaster@${tld}";
    webHosts = [ "0.0.0.0" ];
    hyperkitty.enable = true;
  };
  services.postfix = {
    relayDomains = [ "hash:/var/lib/mailman/data/postfix_domains" ];
    config.transport_maps = [ "hash:/var/lib/mailman/data/postfix_lmtp" ];
    config.local_recipient_maps = [ "hash:/var/lib/mailman/data/postfix_lmtp" ];
  };
  networking.firewall.allowedTCPPorts = [ 80 ];
}
