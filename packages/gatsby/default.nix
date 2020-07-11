{
  pkgs ? import <nixpkgs> {},
  mkDerivation ? pkgs.stdenv.mkDerivation,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  mkYarnPackage ? pkgs.mkYarnPackage,
}: mkYarnPackage {
  name = "gatsby";
  packageJSON = "./packages/gatsby-cli/package.json";
  src = fetchFromGitHub {
    owner = "gatsbyjs";
    repo = "gatsby";
    rev = "gatsby@2.24.0";
    sha256 = "04xxbvd36lnzddvzbag14cviy0hlx3b5zysg8xkyvs98jxkrcni1";
  };
}
