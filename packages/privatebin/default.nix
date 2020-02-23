{ pkgs ? import <nixpkgs> {}, mkDerivation ? pkgs.stdenv.mkDerivation, fetchFromGitHub ? pkgs.fetchFromGitHub }:

mkDerivation {
  name = "privatebin";
  src = fetchFromGitHub {
    owner = "privatebin";
    repo = "privatebin";
    rev = "12c83a13c77eb9246e9bf94e112bb51494390905";
    sha256 = "0yiffj1sl1l5bvv2swi5srbsqpvpp3r9xaw7gsnip6hw1s3cszgr";
  };
  installPhase = ''
    cp -ar $src $out
  '';
}
