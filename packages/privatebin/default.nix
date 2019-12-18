{ pkgs ? import <nixpkgs> {} mkDerivation ? pkgs.stdenv.mkDerivation, fetchFromGitHub ? pkgs.fetchFromGitHub }:

mkDerivation {
  name = "privatebin";
  src = fetchFromGitHub {
    owner = "PrivateBin";
    repo = "PrivateBin";
    rev = "825f6884be3fbfde3ed7d1e05502fdc877af8622";
    sha256 = "11a96650g97az1f3ww5924k88yzxrwcw0f5chazi96srbg3jy9g7";
  };
  installPhase = ''
    mkdir -p $out
    cp -ar $src $out
    chmod -R 755 $out
  '';
}
