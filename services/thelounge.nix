{ config, ... }:
let
    ldapAccount = import /var/secrets/thelounge.nix;
in {
    services.thelounge = {
        enable = true;
        port = 16667;
        extraConfig = {
            bind = "127.0.0.1";
            lockNetwork = true;
            defaults = {
                name = "Redbrick";
                host = "127.0.0.1";
                port = 6667;
                tls = false;
                password = "";
                join = "#lobby,#intersocs,#bots,#helpdesk";
            };
            ldap = {
                enable = true;
                url = config.users.ldap.server;
                primaryKey = "uid";
                searchDN = {
                    base = config.users.ldap.base;
                    filter = "(objectClass=posixAccount)";
                    rootDN = ldapAccount.dn;
                    rootPassword = ldapAccount.password;
                };
            };
        };
    };
}
