{
  imports = [
    ./hardware-configuration.nix
    ../../common/sysconfig.nix
    ../../services/ssh.nix
    ../../services/httpd
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  networking = {
    hostName = "butlerxvm";
    hostId = "6df4f83d";
    defaultGateway = "192.168.0.254";
    interfaces.enp1s0.ipv4.addresses = [{
      address = "192.168.0.136";
      prefixLength = 24;
    }];
  };
}
