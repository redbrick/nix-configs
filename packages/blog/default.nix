{
  pkgs ? import <nixpkgs> {},
  mkDerivation ? pkgs.stdenv.mkDerivation,
  fetchgit ? pkgs.fetchgit,
  hugo ? pkgs.hugo
}: mkDerivation {
  name = "blog";
  buildInputs = [ hugo ];
  src = fetchgit {
    url = "https://git.redbrick.dcu.ie/Redbrick/blog.git";
    sha256 = "1g9vzg6jf21kwi9plc0ja2ln7wjcmzhid78hiywp0sfzy8ax2fva";
  };
  installPhase = ''
    make setup
    make build
    cp -ar $src/public $out
  '';
}
