{ pkgs ? import <nixpkgs> {} }:
let
  versionModule = {
    system.nixos.versionSuffix = "redbrick.netboot";
    system.nixos.revision = "netboot";
  };

  mainModule = {
    imports = [
      ./configuration.nix
      <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    ];
  };

  configEvaled = import <nixpkgs/nixos/lib/eval-config.nix> {
    system = "x86_64-linux";
    modules = [ versionModule mainModule ];
  };
  build = configEvaled.config.system.build;
in pkgs.symlinkJoin {
  name = "netboot";
  paths = with build; [ netbootRamdisk kernel netbootIpxeScript ];
  preferLocalBuild = true;
}
