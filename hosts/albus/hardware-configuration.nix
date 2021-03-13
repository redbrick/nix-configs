{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ohci_pci" "ehci_pci" "megaraid_sas" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "zroot/nixos";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zroot/nixos/store";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/FA00-1459";
      fsType = "vfat";
    };

  fileSystems."/zbackup/generic" =
    { device = "zbackup/generic";
      fsType = "zfs";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/3bb3b7df-a7eb-402f-91a7-037403d36d05"; }
    ];

}
