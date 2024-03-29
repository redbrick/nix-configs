# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "mpt3sas" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "zroot/nixos";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zroot/nixos/store";
      fsType = "zfs";
    };

  fileSystems."/storage" =
    { device = "icarus.internal:/zbackup";
      fsType = "nfs";
    };
  systemd.targets.nfs-client.requiredBy = [ "storage.mount" ];
  systemd.targets.nfs-client.before = [ "storage.mount" ];
  
  swapDevices =
    [ { device = "/dev/disk/by-uuid/b99bbf80-002b-4c10-9d72-96195bb64f4f"; priority = 100; }
      { device = "/dev/disk/by-uuid/49a2deff-5fcc-4736-895b-130202648b59"; priority = 100; }
    ];

  nix.maxJobs = lib.mkDefault 16;
}
