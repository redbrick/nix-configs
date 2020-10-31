{ config, pkgs, ... }:
let
  variables = import ../../common/variables.nix;
in {
  imports = [
    <nixpkgs/nixos/modules/installer/netboot/netboot-minimal.nix>
    ../../common/sysconfig.nix
    ../../services/ssh.nix
  ];

  system.stateVersion = "21.03";

  networking.hostName = "netbootos";
  networking.hostId = "a1b2c3d4";

  # Try to connect to the vlan
  networking.usePredictableInterfaceNames = false;
  networking.vlans.internalA = {
    id = 3;
    interface = "eth0";
  };

  networking.vlans.internalB = {
    id = 3;
    interface = "eth1";
  };

  networking.interfaces.eth0.useDHCP = false;
  networking.interfaces.eth1.useDHCP = false;
  networking.interfaces.eth2.useDHCP = false;
  networking.interfaces.eth3.useDHCP = false;

  networking.interfaces.internalA = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "192.168.0.213";
      prefixLength = 24;
    }];
  };
  networking.interfaces.internalB = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "192.168.0.214";
      prefixLength = 24;
    }];
  };

  environment.systemPackages = with pkgs; [ lsiutil megacli ipmitool ];

  # Set static root password
  users.users.root.hashedPassword = "$6$tcVSiH45Z$E5FmEbXOypPfnCiWF3V7oQS/0jj/JNKlHfnR/Gfn6jzhe52JHcxw07Lbe0w5ZlqxjuAix2pCzHyr1j.fKW.om/";
}
