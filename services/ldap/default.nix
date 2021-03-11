# Required initial setup:
# Add /var/secrets/ldap.secret
# Add /var/secrets/slurpd.secret if setting up a slave
# Add /var/db/ldap/DB_CONFIG
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
        olcLogLevel = "sync";
        olcServerID = builtins.map (srv: (
          "${builtins.toString srv.replicationId} ldap://${srv.ipAddress}:389"
        )) config.redbrick.ldapServers;
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
            olcSyncrepl = builtins.map (srv: (
              "rid=${lib.fixedWidthNumber 3 srv.replicationId} provider=ldap://${srv.ipAddress}:389"
              + " searchbase=\"o=redbrick\" scope=sub"
              + " bindmethod=simple binddn=\"cn=slurpd,ou=ldap,o=redbrick\" credentials=\"${lib.fileContents slurpdpwFile}\""
              + " type=refreshOnly interval=00:00:00:10 retry=\"5 5 300 +\" timeout=1 network-timeout=5"
            )) config.redbrick.ldapServers;
            olcDbIndex = [
              "entryUUID  eq"
              "entryCSN  eq"
            ];
            # TODO figure out how to set this correctly...
            olcMirrorMode = "TRUE";
          };
          children = {
            "olcOverlay={0}syncprov".attrs = {
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
