{
  pkgs ? import <nixpkgs> {},
  mkDerivation ? pkgs.stdenv.mkDerivation,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  mkYarnPackage ? pkgs.mkYarnPackage,
}: mkYarnPackage {
  name = "react-site";
  src = fetchFromGitHub {
    owner = "redbrick";
    repo = "react-site";
    rev = "b2c47221f3ed0058ec9ac769a291a0cc3017be4e";
    sha256 = "04xxbvd36lnzddvzbag14cviy0hlx3b5zysg8xkyvs98jxkrcni1";
  };
}
