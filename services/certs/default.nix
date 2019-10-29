let
  common = import ../../common/variables.nix;
in {
  imports = [
    ./rbacme.nix
  ];

  security.acme = {
    legoCerts."${common.tld}" = {
      email = "admins+acme@${common.tld}";
      dnsProvider = "rfc2136";
      credentialsFile = "/var/secrets/certs.secret";
      extraDomains."*.${common.tld}" = null;
    };
  };
}
