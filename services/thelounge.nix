{ pkgs, config, ... }:
let
    identityFile = "/var/secrets/id_ed25519";
    ldapAccount = import /var/secrets/thelounge.nix;
    identPort = 1113;
    oidentdConfig = pkgs.writeText "oident.conf" ''
      user "thelounge" {
        default {
          allow spoof
          allow spoof_all
          force forward 127.0.0.1 ${builtins.toString identPort}
        }
      }
    '';
in {
    services.thelounge = {
        enable = true;
        port = 16667;
        extraConfig = {
            leaveMessage = "Bye for now";
            lockNetwork = true;
            defaults = {
                name = "Redbrick";
                host = "irc.redbrick.dcu.ie";
                port = 6697;
                tls = true;
                password = "";
                join = "#lobby,#intersocs,#bots,#helpdesk";
            };
            identd = {
                enable = true;
                port = identPort;
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

    systemd.services.oidentd = {
      description = "identd server, routing requests to TheLounge";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.oidentd}/bin/oidentd -c ${oidentdConfig} -i -S";
      };
    };

    networking.firewall.allowedTCPPorts = [ 113 ];
}
