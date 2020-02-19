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
      mkdir -p $out
      ${unzip}/bin/unzip -d $out $renamed
      mv "$unpackDir" "$out"
    '';
  } // removeAttrs args [ "version" ]));
in (map (plugin: {
  name = plugin.name;
  src = fetchPlugins ({
    name = plugin.name;
    version = plugin.version;
    sha256 = plugin.sha256;
  });
}) plugins)
