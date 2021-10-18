{ config, pkgs, ... }:
let
  variables = import ../../common/variables.nix;
in {
  imports = [
    ./hardware-configuration.nix
    ../../common/sysconfig.nix
    ../../services/ssh.nix
    ../../services/postgres.nix
    ../../services/gitea.nix
    ../../services/icecast.nix
    ../../services/thelounge.nix
    ../../services/certs
    ../../services/httpd
    ../../services/postfix
    ../../services/dovecot
    ../../services/grafana
    ../../services/loki.nix
    ../../services/prometheus.nix
    ../../services/promtail.nix
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking = {
    hostName = "hardcase";
    hostId = "0ae64a79";
    defaultGateway = "192.168.0.254";

    # Allow rainloop to connect to mail server over SSL
    hosts = {
      "192.168.0.26" = [ "mail.redbrick.dcu.ie" ];
    };
  } // (variables.bondConfig [ "eno1" "eno2" ] "192.168.0.158");
}
