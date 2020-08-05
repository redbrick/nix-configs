{
  pkgs ? import <nixpkgs> { inherit system; },
  system ? builtins.currentSystem,
}:
let
  nodePackages = import ./default.nix {
    inherit pkgs system;
  };

  # node2nix appends the URL as part of the package name...
  reactSiteName = with builtins; head (filter (
    pkgName: (substring 0 10 pkgName) == "react-site"
  ) (attrNames nodePackages));
in
nodePackages // {
  react-site = with pkgs; nodePackages.${reactSiteName}.override {
    buildInputs = [ vips ];
    nativeBuildInputs = [ pkgconfig gobject-introspection ];
    preRebuild = ''
      ln -s ${pngquant}/bin/pngquant node_modules/pngquant-bin/vendor/pngquant
    '';
  };
}
