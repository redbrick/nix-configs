let
  common = import ../common/variables.nix;
in {
  services.postfix = {
    enable = true;
    setSendmail = true;
    origin = common.tld;
    hostname = "mail.${common.tld}";
    destination = ["mail.${common.tld}" "localhost"];
    recipientDelimiter = "+";
    extraConfig = ./extra.conf;
  };

  networking.firewall.allowedTCPPorts = [ 25 587 ];
}
