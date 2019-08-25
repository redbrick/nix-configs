{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/sysconfig.nix
    ../../services/ssh.nix
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
    interfaces.eno1.ipv4.addresses = [{
      address = "192.168.0.158";
      prefixLength = 24;
    }];
  };
}
