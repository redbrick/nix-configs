{ config, lib, pkgs, modulesPath, ... }:
let
  common = import ../../common/variables.nix;
in {
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "megaraid_sas" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "zicarus/nixos";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zicarus/nixos/store";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/7120-00CA";
      fsType = "vfat";
    };

  fileSystems."/gstorage/brick1/gvhomes" = common.zfsMountConfig "zbrick1/gvhomes";
  fileSystems."/gstorage/brick2/gvhomes" = common.zfsMountConfig "zbrick2/gvhomes";
  fileSystems."/gstorage/brick3/gvhomes" = common.zfsMountConfig "zbrick3/gvhomes";

  fileSystems."/gstorage/brick1/gvservices" = common.zfsMountConfig "zbrick1/gvservices";
  fileSystems."/gstorage/brick2/gvservices" = common.zfsMountConfig "zbrick2/gvservices";
  fileSystems."/gstorage/brick3/gvservices" = common.zfsMountConfig "zbrick3/gvservices";

  fileSystems."/gstorage/brick1/gvarchive" = common.zfsMountConfig "zbrick1/gvarchive";
  fileSystems."/gstorage/brick2/gvarchive" = common.zfsMountConfig "zbrick2/gvarchive";
  fileSystems."/gstorage/brick3/gvarchive" = common.zfsMountConfig "zbrick3/gvarchive";

  fileSystems."/zbackup" = (common.zfsMountConfig "zbackup") // {
    options = [ "relatime" "nosuid" "nodev" ];
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/68cc7ac0-64e3-4fff-9fd9-d11002e8a431"; }
      { device = "/dev/disk/by-uuid/a99c4fbb-9b64-41be-8aa5-124cb01bb558"; }
    ];

  nix.maxJobs = lib.mkDefault 8;
}
