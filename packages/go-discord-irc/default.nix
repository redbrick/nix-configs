{ stdenv, buildGoPackage, pkgs ? import <nixpkgs> {} }:

buildGoPackage rec {
  name = "go-discord-irc";
  version = "20201026-${stdenv.lib.strings.substring 0 7 rev}";
  rev = "718c85cd733bca964abf03f5371c939d19845f72";

  goPackagePath = "github.com/qaisjp/${name}";

  src = pkgs.fetchFromGitHub {
    owner = "qaisjp";
    repo = name;
    sha256 = "1lbdjmyby8iz0782y9mfshl5a6b7isn2b2zavgsflrfj90s82xam";
  };

  goDeps = ./deps.nix;

  meta = {
    homepage    = "https://${goPackagePath}";
    description = "The Discord and IRC bridge with puppets!";
    platforms   = stdenv.lib.platforms.unix;
    maintainers = with stdenv.lib.maintainers; [ butlerx ];
    license     = stdenv.lib.licenses.mit;
  };
}
