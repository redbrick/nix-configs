{ pkgs, mkDerivation ? pkgs.stdenv.mkDerivation, writeText ? pkgs.writeText }:
let
  template = import ./template.nix;

  mkPage = {title, subtitle, message, method}: writeText
    (builtins.toString method)
    (template {inherit title subtitle message;});

  pages = builtins.map mkPage [
    {
      title = "";
      subtitle = "";
      message = "";
      method = 404;
    }
    {
      title = "";
      subtitle = "";
      message = "";
      method = 404;
    }
    {
      title = "";
      subtitle = "";
      message = "";
      method = 404;
    }
  ];

  pageCopyCmds = (builtins.concatStringsSep "\n" (builtins.map (err_page: "cp ${err_page} $out/") pages));
in mkDerivation {
  name = "httpd-error-pages";
  src = ./includes;
  installPhase = ''
    mkdir -p $out
    cp -ar $src/ $out
    ${pageCopyCmds}
  '';
}
