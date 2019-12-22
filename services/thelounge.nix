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

    # TODO remove when ircd-hybrid is listening on a 192.168.0.0/24 address
    systemd.services.irc-tunnel = {
      description = "IRC tunnel";
      before = [ "thelounge.service" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
          ExecStart = ''
            ${pkgs.openssh}/bin/ssh -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' \
            -i ${identityFile} -vNL 6667:irc.redbrick.dcu.ie:6667 portfwd@zeus.internal
          '';
          Restart = "always";
          RestartSec = "10";
          WorkingDirectory = "/var/empty";
      };
    };

    networking.firewall.allowedTCPPorts = [ 113 ];
}
