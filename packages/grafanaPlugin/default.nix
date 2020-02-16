{ pkgs, plugins, fetchurl ? pkgs.fetchurl, unzip ? pkgs.unzip }:

let
  fetchPlugins = { name, version ? "latest", ... } @ args: (fetchurl ({
    inherit name;
    url = "https://grafana.com/api/plugins/${name}/versions/${version}/download";
    recursiveHash = true;
    downloadToTemp = true;
    postFetch = ''
      unpackDir="$TMPDIR/unpack"
      mkdir "$unpackDir"
      cd "$unpackDir"
      renamed="$TMPDIR/${name}.zip"
      mv "$downloadedFile" "$renamed"
      unpackFile "$renamed"
      if [ $(ls "$unpackDir" | wc -l) != 1 ]; then
        echo "error: zip file must contain a single file or directory."
        exit 1
      fi
      fn=$(cd "$unpackDir" && echo *)
      if [ -f "$unpackDir/$fn" ]; then
        mkdir $out
      fi
      mv "$unpackDir/$fn" "$out"
    '';
  } // removeAttrs args [ "version" ])).overrideAttrs (x: {
    # Hackety-hack: we actually need unzip hooks, too
    nativeBuildInputs = x.nativeBuildInputs ++ [ unzip ];
  });
in (map (plugin: {
  name = plugin.name;
  src = fetchPlugins ({
    name = plugin.name;
    version = plugin.version;
    sha256 = plugin.sha256;
  });
}) plugins)
