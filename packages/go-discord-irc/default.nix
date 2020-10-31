{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  metadata = import ./metadata.nix;
in buildGoModule rec {
  pname = "go-discord-irc";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "qaisjp";
    repo = pname;
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  vendorSha256 = metadata.vendorSha256;

  meta = with stdenv.lib; {
    homepage    = "https://github.com/qaisjp/go-discord-irc";
    description = "The Discord and IRC bridge with puppets!";
    platforms   = platforms.unix;
    maintainers = with maintainers; [ butlerx ];
    license     = licenses.mit;
  };
}
