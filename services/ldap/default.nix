# Required initial setup:
# Add /var/secrets/ldap.secret
# Add /var/secrets/slurpd.secret if setting up a slave
# Add /var/db/ldap/DB_CONFIG
{ pkgs, config, lib, ... }:
let
  rootpwFile = "/var/secrets/ldap.secret";
  baseDN = "o=redbrick";
  rootDN = "cn=root,ou=services,o=redbrick";
  slurpdDN = "cn=slurpd,ou=services,${baseDN}";
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
            "{0}to dn.subtree=${baseDN} by dn.exact=${slurpdDN} manage  by dn.exact=${rootDN} manage"
            "{2}to dn.children=ou=accounts,${baseDN}  attrs=cn  by dn.regex=cn=mediawiki,ou=reserved,${baseDN} read  by self read by * none"
            "{3}to attrs=yearsPaid,year,course,id,newbie,altmail  by dn.regex=cn=mediawiki,ou=reserved,${baseDN} read  by self read  by * none"
            "{4}to attrs=userPassword  by dn.regex=cn=dovecot,ou=reserved,${baseDN} read  by self write  by anonymous auth  by * none"
            "{5}to attrs=gecos,loginShell  by self write  by * read"
            "{6}to *  by * read"
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
            olcSuffix = baseDN;
            olcRootDN = rootDN;
            olcRootPW = {
              path = rootpwFile;
            };
            olcSyncrepl = builtins.map (srv: (
              "rid=${lib.fixedWidthNumber 3 srv.replicationId} provider=ldap://${srv.ipAddress}:389"
              + " searchbase=\"${baseDN}\" scope=sub"
              + " bindmethod=simple binddn=\"${slurpdDN}\" credentials=\"${lib.fileContents slurpdpwFile}\""
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
