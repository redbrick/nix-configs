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
    enable = true;

    settings = {
      attrs = {
        olcLogLevel = "0";
        # Used in emergencies
        # olcReadOnly = "TRUE";
      };
      children = {
        "cn=schema".includes = [
          "${pkgs.openldap.out}/etc/schema/core.ldif"
          "${pkgs.openldap.out}/etc/schema/cosine.ldif"
          "${pkgs.openldap.out}/etc/schema/inetorgperson.ldif"
          "${./schema/common.ldif}"
          "${./schema/system.ldif}"
          "${./schema/userdb.ldif}"
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
          } // (lib.optionalAttrs (config.redbrick.ldapSlaveTo != null) {
              olcSyncrepl = "rid=000 provider=ldap://${config.redbrick.ldapSlaveTo}:389 bindmethod=simple timeout=0 network-timeout=0 binddn=\"cn=slurpd,ou=ldap,o=redbrick\" credentials=\"${lib.fileContents slurpdpwFile}\" keepalive=0:0:0 starttls=no filter=\"(objectclass=*)\" searchbase=\"o=redbrick\" scope=sub attrs=\"*,+\" schemachecking=off type=refreshAndPersist retry=\"5 5 300 +\"";
              olcMirrorMode = "FALSE";
          });
          children = {
            # TODO test + repl config
            "olcOverlay={0}syncprov".attrs = lib.optionalAttrs (config.redbrick.ldapSlaveTo == null) {
              objectClass = [ "olcOverlayConfig" "olcSyncProvConfig" ];
              olcOverlay = "{0}syncprov";
              olcSpCheckpoint = "100 10";
            };
          };
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 389 ];
}
