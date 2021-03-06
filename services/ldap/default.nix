# Required initial setup:
# Add /var/secrets/ldap.secret
# Add /var/secrets/slurpd.secret if setting up a slave
# Add /var/db/ldap/DB_CONFIG
{ pkgs, config, lib, ... }:
let
  rootpwFile = "/var/secrets/ldap.secret";
  baseDN = "o=redbrick";
  rootDN = "cn=root,ou=services,o=redbrick";
  slurpdDN = "uid=slurpd,ou=services,${baseDN}";
  slurpdpwFile = "/var/secrets/slurpd.pwd.secret";
  dbDirectory = "/var/db/openldap";
  cluster = config.redbrick.ldapServers.${config.redbrick.ldapCluster};
in {
  # Enable quick graceful shutdown
  systemd.services.openldap.serviceConfig.KillSignal = "SIGINT";

  # Create DB_CONFIG file on startup
  systemd.services.openldap.preStart = ''
    mkdir -p ${dbDirectory}
    cat > ${dbDirectory}/DB_CONFIG << EOF
    set_cachesize 0 2097152 0
    set_lk_max_objects 1500
    set_lk_max_locks 1500
    set_lk_max_lockers 1500
    EOF
  '';

  services.openldap = {
    enable = true;
    # Host-specific listening IP should go into host's configuration.nix
    urlList = [ "ldap://127.0.0.1:389" ];

    settings = {
      attrs = {
        olcServerID = builtins.map (srv: (
          "${builtins.toString srv.replicationId} ldap://${srv.ipAddress}:389"
        )) cluster;
        olcLogLevel = "0";
        # Used for debugging
        # olcLogLevel = "Sync Stats";
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
            "{0}to attrs=yearsPaid,year,course,id,newbie,altmail  by dn.exact=${slurpdDN} manage  by dn.exact=cn=mediawiki,ou=reserved,${baseDN} read  by self read  by * none"
            "{1}to attrs=userPassword  by dn.exact=${slurpdDN} manage  by dn.exact=cn=dovecot,ou=reserved,${baseDN} read  by self write  by anonymous auth  by * none"
            "{2}to attrs=gecos,loginShell  by dn.exact=${slurpdDN} manage  by self write  by * read"
            "{3}to dn.subtree=${baseDN} by dn.exact=${slurpdDN} manage  by * read"
            "{4}to *  by * read"
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
              + " type=refreshOnly interval=00:00:00:10 retry=\"15 20 60 +\""
            )) cluster;
            olcDbIndex = [
              "entryUUID  eq"
              "entryCSN  eq"
              "uid  eq"
            ];
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

  # Configure backups of LDAP
  redbrick.rbbackup.sources = [ "ldap.ldif.gz" ];
  redbrick.rbbackup.extraPackages = with pkgs; [ openldap gzip ];
  redbrick.rbbackup.commands = ''
    ldapsearch -b o=redbrick -xLLL -D ${slurpdDN} -y ${slurpdpwFile} | gzip -8 > ldap.ldif.gz
    chmod 400 ldap.ldif.gz
  '';

  networking.firewall.allowedTCPPorts = [ 389 ];
}
