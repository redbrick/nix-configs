{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  metadata = import ./metadata.nix;
in buildGoModule rec {
  pname = "icecast_exporter";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "markuslindenberg";
    repo = pname;
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  vendorSha256 = metadata.vendorSha256;

  meta = with stdenv.lib; {
    homepage    = "https://github.com/markuslindenberg/icecast_exporter";
    description = "Icecast exporter for Prometheus";
    platforms   = platforms.unix;
    maintainers = with maintainers; [ markuslindenberg ];
    license     = licenses.apache2;
  };
}
