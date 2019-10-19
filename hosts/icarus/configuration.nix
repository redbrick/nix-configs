{ config, pkgs, ... }:
let
  variables = import ../../common/variables.nix;
in {
  imports = [
    ./hardware-configuration.nix
    ../../common/sysconfig.nix
    ../../services/ssh.nix
    ../../services/gluster.nix
    ../../services/ldap
    ../../services/zfsquota
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
    hostName = "icarus";
    hostId = "94851fc9";
    defaultGateway = "192.168.0.254";
  } // (variables.bondConfig [ "eno1" "eno2" ] "192.168.0.150");

  # Set as ldap slave to daedalus
  redbrick.ldapSlaveTo = "daedalus.internal";

  # Icarus is providing /storage for now
  services.nfs.server.exports = ''
    /zbackup  *(sec=sys,rw,no_subtree_check,no_root_squash)
  '';

  # Sync quotas with LDAP
  redbrick.zfsquotaDataset = "zbackup";
  redbrick.zfsquotaSize = "300M";
}
