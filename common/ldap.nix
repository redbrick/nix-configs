# Configuration of LDAP cluster.
# Add new servers here.
# IP Address used instead of DNS to mitigate
# LDAP failures if DNS goes down.
{ config, lib, ... }:
let
  servers = {
    redbrick = [
      {
        hostName = "daedalus.internal";
        ipAddress = "192.168.0.50";
        replicationId = 50;
      }
      {
        hostName = "icarus.internal";
        ipAddress = "192.168.0.150";
        replicationId = 150;
      }
      {
        hostName = "albus.internal";
        ipAddress = "192.168.0.56";
        replicationId = 56;
      }
    ];
    redbricktest = [
      {
        hostName = "m1cr0man.internal";
        ipAddress = "192.168.0.135";
        replicationId = 135;
      }
      {
        hostName = "butlerxvm.internal";
        ipAddress = "192.168.0.136";
        replicationId = 136;
      }
    ];
  };
  cluster = servers.${config.redbrick.ldapCluster};
in {
  redbrick.ldapServers = servers;

  # Enable LDAP
  users.ldap = {
    enable = true;
    daemon.enable = true;
    timeLimit = 2;
    base = "o=redbrick";
    # Two maps over LDAP servers - so that IP address comes after
    # host redundancy.
    # Always use localhost when available
    server = builtins.concatStringsSep " " (
      (lib.optional (config.services.openldap.enable) "ldap://127.0.0.1")
      ++ (builtins.map
        (srv: "ldap://${srv.hostName}")
        cluster
      ) ++ (builtins.map
        (srv: "ldap://${srv.ipAddress}")
        cluster
      )
    );
  };

  # Increasing this limit helps with phpfpm/httpd startup issues
  systemd.services.nscd.serviceConfig.LimitNOFILE = 32768;
  services.nscd.config = ''
    # We basically use nscd as a proxy for forwarding nss requests to appropriate
    # nss modules, as we run nscd with LD_LIBRARY_PATH set to the directory
    # containing all such modules
    # Note that we can not use `enable-cache no` As this will actually cause nscd
    # to just reject the nss requests it receives, which then causes glibc to
    # fallback to trying to handle the request by itself. Which won't work as glibc
    # is not aware of the path in which the nss modules live.  As a workaround, we
    # have `enable-cache yes` with an explicit ttl of 0
    # Redbrick Modification (m1cr0man 16-nov-19): Enable the caching for passwd
    # and group, and set reload-count to 0 to avoid unnecessary refreshes.
    # Changed hosts cache time to 3 minutes from 10
    server-user             nscd

    enable-cache            passwd          yes
    positive-time-to-live   passwd          120
    negative-time-to-live   passwd          120
    reload-count            passwd          0
    shared                  passwd          yes

    enable-cache            group           yes
    positive-time-to-live   group           120
    negative-time-to-live   group           120
    reload-count            group           0
    shared                  group           yes

    enable-cache            netgroup        yes
    positive-time-to-live   netgroup        0
    negative-time-to-live   netgroup        0
    reload-count            netgroup        0
    shared                  netgroup        yes

    enable-cache            hosts           yes
    positive-time-to-live   hosts           180
    negative-time-to-live   hosts           000
    reload-count            hosts           0
    shared                  hosts           yes

    enable-cache            services        yes
    positive-time-to-live   services        0
    negative-time-to-live   services        0
    reload-count            services        0
    shared                  services        yes
  '';
}
