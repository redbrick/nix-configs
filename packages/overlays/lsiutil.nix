{ pkgs ? import <nixpkgs> {}, ... }:
let
  variables = import ../../common/variables.nix;

  lsiutilNew = pkg: pkg.overrideAttrs (oldattrs: {
    version = "1.70";
    src = pkgs.fetchFromGitHub {
      owner = "mute55";
      repo = "LSIUtil";
      rev = "106857e2f9f218513c95e5778a0fd0b88e73ec48";
      sha256 = "1svmd464dgq9ydfcnxig37dq8j551l2ln6lh5sbjjrk1rwra1clc";
    };
    srcs = [];
    sourceRoot = "source/Source/1.70";
    preBuild = ''
      mv Makefile_Linux Makefile
    '' + oldattrs.preBuild;
  });
in {
  nixpkgs.overlays = [ (self: super: {
    lsiutil = lsiutilNew super.lsiutil;
  }) ];
}
