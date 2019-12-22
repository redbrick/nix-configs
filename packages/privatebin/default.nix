{ pkgs ? import <nixpkgs> {}, mkDerivation ? pkgs.stdenv.mkDerivation, fetchFromGitHub ? pkgs.fetchFromGitHub }:

mkDerivation {
  name = "privatebin";
  src = fetchFromGitHub {
    owner = "m1cr0man";
    repo = "PrivateBin";
    rev = "6b0468ebff2883b4bd395dbdb3c581fa9936ee24";
    sha256 = "1g9vzg6jf21kwi9plc0ja2ln7wjcmzhid78hiywp0sfzy8ax2fva";
  };
  installPhase = ''
    cp -ar $src $out
  '';
}
