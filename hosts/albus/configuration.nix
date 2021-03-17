{ config, pkgs, lib, ... }:
let
  variables = import ../../common/variables.nix;
in {
  imports = [
    ./hardware-configuration.nix
    ../../common/sysconfig.nix
    ../../services/ssh.nix
    ../../services/ldap
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.03";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.devices = [
    "/dev/disk/by-id/wwn-0x6b083fe0e2c9d90027400280071d8c39"
  ];

  networking = {
    hostName = "albus";
    hostId = "92975c99";
    defaultGateway = "192.168.0.254";
  } // (variables.bondConfig [ "eno1" "eno2" ] "192.168.0.56");

  services.openldap.urlList = [ "ldap://192.168.0.56:389" ];

  # Keep longer monthly snapshots
  services.zfs.autoSnapshot.monthly = lib.mkForce 3;

  # Albus _is_ the backup hosts - change rbbackup destination
  redbrick.rbbackup.destination = "/zbackup/generic/albus/";

  users.users.rbbackup = {
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHM+HZVUPkFX/Xlxla/2JYpFrt2vEG2nJVcjRpJhGU3c root@daedalus"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjw3ENwy/fBX6EOqwppSv1c0m5buvKE8OaS810BTaFo root@icarus"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLnjvcD8MnRKf5YDvKqDWK+kGMfYhSb9l54jW8nd0H1 root@m1cr0man"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBvBThPI3TmXVOKrY39l0rFLOdaLl0a0Xh/IaRQ+tAA+ root@butlerxvm"
    ];
  };

  systemd.services.rbbackup-permissions = {
    description = "Configure ZFS permissions for rbbackup user";
    after = [ "zfs-import.target" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = true;
    path = with pkgs; [ zfs ];
    script = ''
      zfs allow -u rbbackup create,destroy,mount,receive,userprop zbackup
      chown -R rbbackup /zbackup/generic
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };
}
