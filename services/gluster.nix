{ pkgs, ... }:
{
  services.glusterfs = {
    enable = true;
    # TODO change in prod
    logLevel = "INFO";
  };

  services.nfs.server.enable = true;

  nixpkgs.overlays = [
    (self: super: {

      glusterfs = super.glusterfs.overrideAttrs (oldAttrs: {
        separateDebugInfo = true;
        name = "glusterfs-7.0";
        version = "7.0rc3";
        meta.version = "7.0rc3";
        src = self.fetchFromGitHub {
          owner = "gluster";
          repo = "glusterfs";
          rev = "bac5d7d60d14a190217fcd84fd0803a4d6a2e37d";
          sha256 = "1y2q0jpnj3z9pwx1azh6ls2x0ciqnfja0vczj0xp9v83l2a6qa02";
        };
      });
    })
  ];

  # For each brick open port 49152 + brick_num
  # Our nodes have 3 bricks
  # Opening a heap of ports to make things easier in the future
  # Max 15 if the powervault was to have 1 brick per drive
  networking.firewall.allowedTCPPorts = [
    111 2049 4045 24007 24008 38465 38466 38467
    49152 49153 49154 49155 49156 49157
    49158 49159 49160 49161 49162 49163
    49164 49165 49166 49167 49168 49169 49170
    20048
  ];
  networking.firewall.allowedUDPPorts = [ 111 2049 4045 ];
}
