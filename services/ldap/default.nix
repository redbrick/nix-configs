# Required initial setup:
# Add /var/secrets/ldap.secret
# Add /var/secrets/slurpd.secret if setting up a slave
# Add /var/db/ldap/DB_CONFIG
# TODO change RID based on IP address of host
{ pkgs, config, lib, ... }:
let
  rootpwFile = "/var/secrets/ldap.secret";
  slurpdpwFile = "/var/secrets/slurpd.secret";
  dbDirectory = "/var/db/openldap";
in {
  services.openldap = {
    inherit rootpwFile;
    enable = true;
    suffix = "o=redbrick";
    rootdn = "cn=root,ou=ldap,o=redbrick";
    defaultSchemas = false; # We don't use the nis.schema
    database = "hdb";

    settings = {
      attrs = {
        olcLogLevel = "0";
        # Used in emergencies
        # olcReadOnly = "TRUE";
      };
      children = {
        "cn=schema".includes = [
          "${pkgs.openldap.out}/etc/schema/core.schema"
          "${pkgs.openldap.out}/etc/schema/cosine.schema"
          "${pkgs.openldap.out}/etc/schema/inetorgperson.schema"
          "${./schema/common.schema}"
          "${./schema/system.schema}"
          "${./schema/userdb.schema}"
        ];
        "olcDatabase={-1}frontend".attrs = {
          objectClass = [ "olcDatabaseConfig" "olcFrontendConfig" ];
          olcDatabase = "{-1}frontend";
          olcSizeLimit = "unlimited";
          olcLastMod = "TRUE";
          olcAccess = [
            "{0}to dn.children=ou=2002,ou=accounts,o=redbrick  by dn.regex=cn=root,ou=ldap,o=redbrick write  by dn.regex=cn=slurpd,ou=ldap,o=redbrick read by * none"
            "{1}to dn.children=ou=accounts,o=redbrick  attrs=cn  by dn.regex=cn=root,ou=ldap,o=redbrick write  by dn.regex=cn=slurpd,ou=ldap,o=redbrick read  by dn.regex=cn=mediawiki,ou=reserved,o=redbrick read  by self read by * none"
            "{2}to attrs=yearsPaid,year,course,id,newbie,altmail  by dn.regex=cn=root,ou=ldap,o=redbrick write  by dn.regex=cn=slurpd,ou=ldap,o=redbrick read  by dn.regex=cn=mediawiki,ou=reserved,o=redbrick read  by self read  by * none"
            "{3}to attrs=userPassword  by dn.regex=cn=root,ou=ldap,o=redbrick write continue  by dn.regex=cn=slurpd,ou=ldap,o=redbrick read  by dn.regex=cn=dovecot,ou=reserved,o=redbrick read  by self write  by anonymous auth  by * none"
            "{4}to attrs=gecos,loginShell  by dn.regex=cn=root,ou=ldap,o=redbrick write continue  by dn.regex=cn=slurpd,ou=ldap,o=redbrick read  by self write  by * read"
            "{5}to *  by * read"
          ];
        };
        "olcDatabase={0}config".attrs = {
          objectClass = "olcDatabaseConfig";
          olcDatabase = "{0}config";
          olcAccess = [ "{0}to * by * none break" ];
        };
        "olcDatabase={1}hdb" = {
          attrs = {
            objectClass = [ "olcDatabaseConfig" "olcHdbConfig" ];
            olcDatabase = "{1}hdb";
            olcAccess = [ "{0}to * by * read break" ];
            olcDbCacheSize = "100000";
            olcLastMod = "TRUE";
            olcMonitoring = "TRUE";
            olcDbDirectory = dbDirectory;
            olcSuffix = "o=redbrick";
            olcRootDN = "cn=root,ou=ldap,o=redbrick";
            olcRootPW = {
              path = rootpwFile;
            };
          };
          children = {
            # TODO test + repl config
            "olcOverlay={0}syncprov".attrs = if (config.redbrick.ldapSlaveTo == null) then {
              objectClass = [ "olcOverlayConfig" "olcSyncProvConfig" ];
              olcOverlay = "{0}syncprov";
              olcSpCheckpoint = "100 10";
              olcAccess = [ "{0}to * by * read break" ];
            } else {
              olcSyncrepl = "rid=000 provider=ldap://${config.redbrick.ldapSlaveTo}:389 bindmethod=simple timeout=0 network-timeout=0 binddn=\"cn=slurpd,ou=ldap,o=redbrick\" credentials=\"${lib.fileContents slurpdpwFile}\" keepalive=0:0:0 starttls=no filter=\"(objectclass=*)\" searchbase=\"o=redbrick\" scope=sub attrs=\"*,+\" schemachecking=off type=refreshAndPersist retry=\"5 5 300 +\"";
              olcMirrorMode = "FALSE";
            };
          };
      };
    };

    extraDatabaseConfig = ''
      cachesize 100000
    '' + (if (config.redbrick.ldapSlaveTo == null) then ''

      # Master config
      overlay syncprov
      syncprov-checkpoint 100 10
    '' else ''
      syncrepl rid=000
        provider=ldap://${config.redbrick.ldapSlaveTo}:389
        type=refreshAndPersist
        retry="5 5 300 +"
        attrs="*,+"
        binddn="cn=slurpd,ou=ldap,o=redbrick"
        bindmethod=simple
        credentials=${lib.fileContents slurpdpwFile}
        searchbase="o=redbrick"
    '');
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
      loglevel ${config.services.openldap.logLevel}

      # ACLs
      access to dn.children="ou=2002,ou=accounts,o=redbrick"
        by dn.regex="cn=root,ou=ldap,o=redbrick" write
        by dn.regex="cn=slurpd,ou=ldap,o=redbrick" read
        by * none

      access to dn.children="ou=accounts,o=redbrick" attrs=cn
        by dn.regex="cn=root,ou=ldap,o=redbrick" write
        by dn.regex="cn=slurpd,ou=ldap,o=redbrick" read
        by dn.regex="cn=mediawiki,ou=reserved,o=redbrick" read
        by self read
        by * none

      access to attrs=yearsPaid,year,course,id,newbie,altmail
        by dn.regex="cn=root,ou=ldap,o=redbrick" write
        by dn.regex="cn=slurpd,ou=ldap,o=redbrick" read
        by dn.regex="cn=mediawiki,ou=reserved,o=redbrick" read
        by self read
        by * none

      access to attrs=userPassword
        by dn.regex="cn=root,ou=ldap,o=redbrick" write continue
        by dn.regex="cn=slurpd,ou=ldap,o=redbrick" read
        by dn.regex="cn=dovecot,ou=reserved,o=redbrick" read
        by self write
        by anonymous auth
        by * none

      access to attrs=gecos,loginShell
        by dn.regex="cn=root,ou=ldap,o=redbrick" write continue
        by dn.regex="cn=slurpd,ou=ldap,o=redbrick" read
        by self write
        by * read

      # Default ACL
      access to *
        by * read
    '';
  };

  networking.firewall.allowedTCPPorts = [ 389 ];
}
