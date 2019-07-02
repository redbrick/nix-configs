{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/sysconfig.nix
    ../../services/ssh.nix
    ../../services/httpd.nix
    ../../services/dns
    ../../services/postfix
    ../../services/dovecot
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "m1cr0man";
  networking.interfaces.enp1s0.ipv4.addresses = [{
    address = "192.168.0.135";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.0.254";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim git jre screen unzip
  ];
}
