{config, lib, ...}:
let
  tld = config.redbrick.tld;
  hyperkittySecret = "/var/secrets/hyperkitty.secret";
in {
  # https://github.com/NixOS/nixpkgs/issues/44426
  # needs to come before all other in alphabetical order (or make use of
  # lib.mkBefore)
  # from https://git.immae.eu/?p=perso/Immae/Config/Nix.git;a=blob;f=overlays/python-packages/default.nix;h=0feff55eea2b5ea220cb135cd1e134a713f0fcca;hb=HEAD
  nixpkgs.overlays = [
    (self: super: let
      pyNames = [ "python37" ];
      overriddenPython = name: [
        { inherit name; value = super.${name}.override { packageOverrides = pyself: pysuper: {
            hyperkitty = pysuper.hyperkitty.overrideAttrs (oldAttrs: rec {
              version = "1.3.2";
              # TODO fix undefined fetchPypi
              src = self.fetchPypi {
                inherit version;
                pname = "HyperKitty";
                sha256 = "wat";
              };
            });
          };
        }; }
        { name = "${name}Packages"; value = self.recurseIntoAttrs self.${name}.pkgs; }
      ];
      overriddenPythons = builtins.concatLists (map overriddenPython pyNames);
    in {
      buildPythonOverrides = newOverrides: currentOverrides: super.lib.composeExtensions newOverrides currentOverrides;
    } // super.lib.attrsets.listToAttrs overriddenPythons)
  ];

  services.mailman = {
    enable = true;
    siteOwner = "postmaster@${tld}";
    webHosts = [ "0.0.0.0" ];
    hyperkittyApiKey = lib.fileContents hyperkittySecret;
  };
  networking.firewall.allowedTCPPorts = [ 80 ];
}
