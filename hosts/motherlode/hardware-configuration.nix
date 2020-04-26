{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "megaraid_sas" "usbhid" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8c34aaec-4f61-4b29-a451-cd8e8d2bd394";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/28c3f2fd-7b98-4bf6-a778-f73b8064c381"; }
    ];

  nix.maxJobs = lib.mkDefault 8;
}
