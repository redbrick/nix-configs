{ config, lib, ... }:
with builtins;
with lib;
let
  common = import ../../common/variables.nix;
  vhosts = import ../httpd/vhosts.nix { inherit config; };
  email = "webmaster+acme@${common.tld}";

  # Filter *.dcu.ie domains
  vhostFilter = vhost:
    !(hasSuffix "dcu.ie" vhost.hostName);

  # Groups vhosts based on the tld + domain
  vhostGroupFunc = vhost: common.domainTld vhost.hostName;

  # Creates a list of all names of a vhost
  allNames = vhostGroup:
    flatten (map (vh: concatLists [vh.serverAliases [vh.hostName]]) vhostGroup);
in {
  imports = [
    ./rbacme.nix
  ];

  security.acme.legoCerts = {
    "${common.tld}" = {
      inherit email;
      dnsProvider = "rfc2136";
      credentialsFile = "/var/secrets/certs.secret";
      extraDomains."*.${common.tld}" = null;
      extraFlags = [ "--dns.disable-cp" ];
    };
  } // (mapAttrs'
    (domain: vhostGroup: nameValuePair

      # If the vhost only has one name, use that, otherwise use the domain
      # For example look at luxgaa.lu
      (if (length (allNames vhostGroup)) == 1 then (head (allNames vhostGroup)) else domain)
      {
        inherit email;
        webroot = common.webtreeCertsDir;

        # Map the values to null, since we don't want to set anything for the extraDomains
        extraDomains = mapAttrs (k: v: null)

          # 2 birds with 1 stone: Turn list into attributes with alias as key, also groups duplicates
          (groupBy (alias: alias)

            # Remove aliases that match the domain
            (filter (alias: alias != domain)

              # Get hostnames and aliases of all vhosts for this domain
              (allNames vhostGroup)
            )
          );
      })
    (groupBy vhostGroupFunc (filter vhostFilter vhosts)));
}
