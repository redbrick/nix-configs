{ config, pkgs, lib, ... }:
let
  variables = import ../../common/variables.nix;
in {
  imports = [
    ./hardware-configuration.nix
    ../../common/sysconfig.nix
    ../../services/ssh.nix
    ../../services/libvirt.nix
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.03";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking = lib.recursiveUpdate {
    hostName = "motherlode";
    hostId = "fccc9415";
    defaultGateway = "192.168.0.254";
    vlans.dculife = {
      id = 5;
      interface = "eno4";
    };
   interfaces.eno4.useDHCP = false;
   interfaces.dculife.useDHCP = false;
  } (variables.bondConfig [ "eno1" "eno2" ] "192.168.0.130");
}
