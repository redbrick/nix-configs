# Configuration of LDAP cluster.
# Add new servers here.
# IP Address used instead of DNS to mitigate
# LDAP failures if DNS goes down.
{
    redbrick.ldapServers = [
        # m1cr0man.internal
        {
            ipAddress = "192.168.0.135";
            replicationId = 135;
        }
        # butlerxvm.internal
        {
            ipAddress = "192.168.0.136";
            replicationId = 136;
        }
        # albus.internal
        {
            ipAddress = "192.168.0.56";
            replicationId = 56;
        }
    ];
}
