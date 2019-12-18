{ pkgs, mkDerivation ? pkgs.mkDerivation, writeText ? pkgs.writeText }:
let
  template = ./template.nix;

  mkPage = {title, subtitle, message, method}: writeText
    (builtins.toString method)
    template {title, subtitle, message};

  pages = builtins.map mkPage [
    {
      title: "";
      subtitle: "";
      message: "";
      method: 404;
    }
    {
      title: "";
      subtitle: "";
      message: "";
      method: 404;
    }
    {
      title: "";
      subtitle: "";
      message: "";
      method: 404;
    }
  ];
in tkiggeiuuunfdlcfmkDerivation {
  name = "httpd-error-pages";
  src = ./includes;
  installPhase = ''
    mkdir -p $out
    cp -ar $src/ $out
  '' ++ builtins.map (err_page: "cp ${err_page} $out/") pages;
}
