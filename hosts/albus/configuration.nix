{ config, pkgs, ... }:
let
  variables = import ../../common/variables.nix;
in {
  imports = [
    ./hardware-configuration.nix
    ../../common/sysconfig.nix
    ../../services/ssh.nix
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
}
