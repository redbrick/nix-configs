{ pkgs, mkDerivation ? pkgs.stdenv.mkDerivation, writeText ? pkgs.writeText }:
let
  template = import ./template.nix;

  mkPage = {title, subtitle, message, method}: writeText
    (builtins.toString method)
    (template {inherit title subtitle message;});

  pages = builtins.map mkPage [
    {
      title = "Error 401";
      subtitle = "Authorization Required";
      message = ''
        Your authorization could not be verified.
        Please check your username and password and try again.
      '';
      method = 401;
    }
    {
      title = "Error 403";
      subtitle = "Access Forbidden";
      message = ''
        You don't have permission to access the requested object.
        It is either read-protected or not readable by the server.
      '';
      method = 403;
    }
    {
      title = "Error 404";
      subtitle = "Requested URL Not Found";
      message = ''
        If you entered the URL manually please check your spelling and try again.
      '';
      method = 404;
    }
    {
      title = "Error 500";
      subtitle = "Internal Server Error";
      message = ''
        Something went wrong while processing your request.
        Please try again.
      '';
      method = 500;
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
