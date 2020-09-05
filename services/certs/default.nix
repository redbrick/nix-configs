{ config, lib, ... }:
with builtins;
with lib;
let
  tld = config.redbrick.tld;
  common = import ../../common/variables.nix;
  vhosts = import ../httpd/vhosts.nix { inherit config; };
  email = "webmaster+acme@${tld}";
  webroot = common.webtreeCertsDir;
  group = "wwwrun";
in {
  security.acme.acceptTerms = true;
  security.acme.certs = {
    "${tld}" = {
      inherit email group;
      dnsProvider = "rfc2136";
      credentialsFile = "/var/secrets/certs.secret";
      extraDomainNames = [ "*.${tld}" ];
      dnsPropagationCheck = false;
    };
  } //
    # Map all domains to a certs attrset
    mapAttrs (certDomain: domains: {
      inherit email group webroot;
      # Remove domains that match the certDomain
      extraDomainNames = filter (domain: domain != certDomain) domains;
    })

      # Combine all common certDomains
      (foldAttrs (next: last: next ++ last) []

        # Map out each vhost into a list of domains under a certDomain
        (mapAttrsToList (hostName: vhost: let
          certDomain = common.certDomain tld hostName;
        in {
          "${certDomain}" = [ hostName ] ++ (vhost.serverAliases or []);
        })

          # Ignore TLD domains, they are covered by the wildcard
          (filterAttrs (hostName: vhost: !(hasSuffix tld hostName)) vhosts)
        )
      );
}
