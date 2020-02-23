{ config, lib, ... }:
with builtins;
with lib;
let
  tld = config.redbrick.tld;
  common = import ../../common/variables.nix;
  vhosts = import ../httpd/vhosts.nix { inherit config; };
  email = "webmaster+acme@${tld}";
  webroot = common.webtreeCertsDir;

in {
  security.acme.acceptTerms = true;
  security.acme.certs = {
    "${tld}" = {
      inherit email;
      dnsProvider = "rfc2136";
      credentialsFile = "/var/secrets/certs.secret";
      extraDomains."*.${tld}" = null;
      dnsPropagationCheck = false;
    };
  } //
    # Map all domains to a certs attrset
    mapAttrs (certDomain: domains: {
      inherit email webroot;
      extraDomains = listToAttrs
        (map (domain: nameValuePair domain null)

          # Remove domains that match the certDomain
          (filter (domain: domain != certDomain) domains));
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
