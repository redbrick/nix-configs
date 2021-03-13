{ config, pkgs, ... }:
let
  variables = import ../../common/variables.nix;
in {
  imports = [
    ./hardware-configuration.nix
    ../../common/sysconfig.nix
    ../../services/ssh.nix
    ../../services/gluster.nix
    ../../services/squid.nix
    ../../services/znapzend.nix
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
  boot.loader.grub.devices = [
    "/dev/disk/by-id/wwn-0x6001ec90d17f2400275982c55f7fa380"
    "/dev/disk/by-id/wwn-0x6001ec90d17f2400275bf01649f1e3d1"
  ];

  networking = {
    hostName = "icarus";
    hostId = "94851fc9";
    defaultGateway = "192.168.0.254";
  } // (variables.bondConfig [ "eno1" "eno2" ] "192.168.0.150");

  services.openldap.urlList = [ "ldap://192.168.0.150:389" ];

  # Icarus is providing /storage for now
  services.nfs.server.exports = ''
    /zbackup  *(sec=sys,rw,no_subtree_check,no_root_squash)
  '';

  # Sync quotas with LDAP
  redbrick.zfsquotaDataset = "zbackup";

  # Configure backups
  redbrick.znapzendSourceDataset = "zbackup";
  redbrick.znapzendDestDataset = "zbackup/nfs";
}
