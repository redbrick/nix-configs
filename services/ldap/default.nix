# Required initial setup:
# Add /var/secrets/ldap.secret
# Add /var/db/ldap/DB_CONFIG
{ pkgs, config, ... }:
let
  rootpwFile = "/var/secrets/ldap.secret";
in {
  services.openldap = {
    inherit rootpwFile;
    enable = true;
    suffix = "o=redbrick";
    rootdn = "cn=root,ou=ldap,o=redbrick";
    defaultSchemas = false; # We don't use the nis.schema
    database = "hdb";
    extraDatabaseConfig = ''
      cachesize 100000
    '';
    extraConfig = ''
      include ${pkgs.openldap.out}/etc/schema/core.schema
      include ${pkgs.openldap.out}/etc/schema/cosine.schema
      include ${pkgs.openldap.out}/etc/schema/inetorgperson.schema
      include ${./schema/common.schema}
      include ${./schema/system.schema}
      include ${./schema/userdb.schema}

      backend hdb
      lastmod on

      sizelimit unlimited

      # ACLs
      access to dn.children="ou=2002,ou=accounts,o=redbrick"
        by dn.regex="cn=root,ou=ldap,o=redbrick" write
        by * none

      access to dn.children="ou=accounts,o=redbrick" attrs=cn
        by dn.regex="cn=root,ou=ldap,o=redbrick" write
        by self read
        by * none

      access to attrs=yearsPaid,year,course,id,newbie,altmail
        by dn.regex="cn=root,ou=ldap,o=redbrick" write
        by self read
        by * none

      access to attrs=userPassword
        by dn.regex="cn=root,ou=ldap,o=redbrick" write continue
        by self write
        by anonymous auth
        by * none

      access to attrs=gecos,loginShell
        by dn.regex="cn=root,ou=ldap,o=redbrick" write continue
        by self write
        by * read

      # Default ACL
      access to *
        by * read
    '';
  };

  networking.firewall.allowedTCPPorts = [ 389 ];
}
