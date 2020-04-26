{ config, ... }:
let
  tld = config.redbrick.tld;
in {

  # Need a cert specifically for the listening port
  # It's hard to get libvirt to work without tls
  security.acme.acceptTerms = true;
  security.acme.certs.libvirt = {
    domain = "${config.networking.hostName}.${tld}";
    email = "webmaster+acmelibvirt@${tld}";
    dnsProvider = "rfc2136";
    credentialsFile = "/var/secrets/certs.secret";
    dnsPropagationCheck = false;
  };

  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
    extraConfig = "listen_tls = 0\nlisten_tcp = 1";
    extraOptions = ["-l"];
  };
}
