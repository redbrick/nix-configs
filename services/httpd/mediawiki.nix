{ config, pkgs, lib, ... }:
with (import ./shared.nix { tld = config.redbrick.tld; });
let
  concatStringsSep = lib.strings.concatStringsSep;

  user = "wiki";
  group = "redbrick";

  dbPasswordFile = "/var/secrets/mw_db.pass";
  secretKeyPath = "/var/secrets/mw_secret.key";
  ldapProviderConfig = "/var/secrets/mw_ldapprovider.json";

  # Generate these with nix-prefetch-github --nix $owner $repo
  extensions = [
    { name = "RSS"; src = pkgs.fetchFromGitHub {
      owner = "wikimedia";
      repo = "mediawiki-extensions-RSS";
      rev = "f3fa923e38d100eb7de95c10962d6fc10ef1d08a";
      sha256 = "1ak4dmiqk74qiraaz9s8cs81jvx70y9gppgph2m82p7fn3ynw9rg";
    }; }
    { name = "PluggableAuth"; src = pkgs.fetchFromGitHub {
      owner = "wikimedia";
      repo = "mediawiki-extensions-PluggableAuth";
      rev = "2d2bdf22b526f33345406b44b23ba9bd6154ba4c";
      sha256 = "06bq3k2nraz1zx3xkaxkcnfb9njrnrf84ah9sv9wb97g61d297a5";
    }; }
    { name = "LDAPProvider"; src = pkgs.fetchFromGitHub {
      owner = "m1cr0man";
      repo = "mediawiki-extensions-LDAPProvider";
      rev = "d77465b78faf25464fe12977be190f6384743198";
      sha256 = "0gz3s44xng0yw38b2c5nmd407nv24lh44hz9169qgm6dqnz2zkrq";
    }; }
    { name = "LDAPAuthorization"; src = pkgs.fetchFromGitHub {
      owner = "wikimedia";
      repo = "mediawiki-extensions-LDAPAuthorization";
      rev = "05defa90b62a78a51415a0b774f25a0d320392aa";
      sha256 = "0kgschbdz0q9knnmbzcl111p6q6lgi9qi82fcl57k2544cpcjcy7";
    }; }
    { name = "LDAPAuthentication2"; src = pkgs.fetchFromGitHub {
      owner = "wikimedia";
      repo = "mediawiki-extensions-LDAPAuthentication2";
      rev = "8b043184ede3a458a8500f8807c250a6629bfbb1";
      sha256 = "10ls2mab7906np4v3ajqvrfrxhgm4yr7pf9gy1h6wxifdgrdizhf";
    }; }
  ];

  pkg = pkgs.mediawiki.overrideAttrs (oldAttrs: {
    postInstall = concatStringsSep "\n"
      (builtins.map (ext: "ln -s ${ext.src} $out/share/mediawiki/extensions/${ext.name}") extensions);
  });
  documentRoot = "${pkg}/share/mediawiki";

  mkConfig = {domain, title, dbName, dbPrefix, cacheDir, stateDir, scriptPath ? "", needLogin ? false}: pkgs.writeText "LocalSettings.${domain}.php" ''
    <?php
      ## Protect against web entry
      if ( !defined( 'MEDIAWIKI' ) ) {
        exit;
      }

      ## General settings
      $wgServer = "https://${domain}";
      $wgSitename = "${title}";
      $wgScriptPath = "${scriptPath}";
      $wgSecretKey = file_get_contents("${secretKeyPath}");
      $wgLogo = "/Wiki.png";

      ## Changing this will log out all existing sessions.
      $wgAuthenticationTokenVersion = "";

      ## This path should not be publically accessible
      $wgCacheDirectory = "${cacheDir}";

      ## Uploads settings
      $wgEnableUploads = true;
      $wgHashedUploadDirectory = true;
      $wgUploadDirectory = "${stateDir}/images";
      $wgUploadPath = "$wgScriptPath/images";
      $wgFileExtensions = array( 'png', 'gif', 'jpg', 'jpeg', 'ogg', 'zip', 'doc', 'xls', 'psd', 'ppt' );

      ## Database settings
      $wgDBtype = "mysql";
      $wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";
      $wgDBserver = "mysql.internal";
      $wgDBuser = "wiki";
      $wgDBpassword = file_get_contents("${dbPasswordFile}");
      $wgDBname = "${dbName}";
      $wgDBprefix = "${dbPrefix}";

      # Email settings
      $wgEnableEmail = true;
      $wgEnableUserEmail = true;
      $wgEmergencyContact = "${adminAddr}";
      $wgPasswordSender = $wgEmergencyContact;
      $wgEnotifUserTalk = true;
      $wgEnotifWatchlist = true;
      $wgEmailAuthentication = true;

      ## Shared memory settings
      ## TODO setup memcached
      $wgMainCacheType = CACHE_NONE;
      $wgMemCachedServers = [];

      ## External utility settings
      $wgUseImageMagick = true;
      $wgImageMagickConvertCommand = "${pkgs.imagemagick}/bin/convert";
      $wgDiff = "${pkgs.diffutils}/bin/diff";
      $wgDiff3 = "${pkgs.diffutils}/bin/diff3";

      # Periodically send a pingback to https://www.mediawiki.org/ with basic data
      # about this MediaWiki instance. The Wikimedia Foundation shares this data
      # with MediaWiki developers to help guide future development efforts.
      $wgPingback = true;

      # Less important general settings
      umask(0033);
      $wgDirectoryMode = 0744;
      $wgUsePathInfo = true;
      $wgResourceBasePath = $wgScriptPath;
      $wgMetaNamespace = false;
      $wgShellLocale = "C.UTF-8";
      $wgAllowExternalImages = true;
      $wgCookieSecure = true; # HTTPS proxy
      $wgLanguageCode = "en";
      $wgRightsPage = "";
      $wgRightsUrl = "";
      $wgRightsText = "";
      $wgRightsIcon = "";

      # Permissions
      $wgNonincludableNamespaces[] = 100;
      $wgGroupPermissions['*']['readrbonly'] = false;
      $wgNamespaceProtection[ 100 ] = array( 'readrbonly' );
      $wgGroupPermissions['*']['createaccount']   = false;
      $wgGroupPermissions['*']['read']            = ${if needLogin then "false" else "true"};
      $wgGroupPermissions['*']['edit']            = false;

      # When you make changes to this configuration file, this will make
      # sure that cached pages are cleared.
      $wgCacheEpoch = max( $wgCacheEpoch, gmdate( 'YmdHis', @filemtime( __FILE__ ) ) );

      # Skins and extensions
      ${concatStringsSep "\n" (builtins.map (ext: "wfLoadExtension('${ext.name}');") extensions)}
      wfLoadSkin('Vector');

      $wgDefaultSkin = 'vector';
      $LDAPProviderDomainConfigs = "${ldapProviderConfig}";
  '';

  vhostWiki = config: cfgPath: (vhost { inherit documentRoot user group; extraConfig = ''
    ProxyTimeout 600
    SetEnv MEDIAWIKI_CONFIG "${cfgPath}"

    RewriteEngine on
    RewriteRule ^rss /index.php/Special:RecentChanges?feed=rss [L,QSA]
    RewriteRule ^/?mw/?(.*)$ /index.php/$1 [L,QSA,R=301]
    RewriteRule ^/*$ /index.php/Main_Page [L,QSA]

    Alias "/Wiki.png" "${config.stateDir}/Wiki.png"
    Alias "/images" "${config.stateDir}/images"
    <Directory "${config.stateDir}">
      Require all granted
    </Directory>
  '';}) // (common.vhostCerts tld);

  # Adapted from the nixpkgs repo mediawiki implementation
  # Skips initial setup, this will never be done at RB. Feel free to port it if you think it will.
  # Don't forget you can use the built-in UI for init
  updateService = cfgPath: {
    wantedBy = [ "multi-user.target" ];
    before = [ "httpd.service" ];
    script = ''
      ${pkgs.php}/bin/php ${pkg}/share/mediawiki/maintenance/update.php --conf ${cfgPath} --quick
    '';
    serviceConfig = {
      Type = "oneshot";
      User = user;
      Group = group;
      PrivateTmp = true;
    };
  };

  wikiConfig = {
    domain = "wiki.${tld}";
    title = "Redbrick Wiki";
    dbName = "wikinew";
    dbPrefix = "rbwiki_";
    cacheDir = "/var/tmp/wiki";
    stateDir = "${webtree}/w/wiki";
  };
  wikiCfgPath = mkConfig wikiConfig;

  cmtWikiConfig = {
    domain = "cmtwiki.${tld}";
    title = "Redbrick Committee Wiki";
    dbName = "cmtwiki";
    dbPrefix = "wiki_";
    cacheDir = "/var/tmp/cmtwiki";
    stateDir = "${webtree}/redbrick/extras/cmt/wiki";
    needLogin = true;
  };
  cmtWikiCfgPath = mkConfig cmtWikiConfig;
in {
  systemd.tmpfiles.rules = [
    "d '/var/tmp/wiki' 0750 ${user} ${group} - -"
    "d '/var/tmp/cmtwiki' 0750 ${user} ${group} - -"
  ];

  systemd.services.wiki-init = updateService wikiCfgPath;
  systemd.services.cmtwiki-init = updateService cmtWikiCfgPath;

  services.httpd.virtualHosts."${wikiConfig.domain}" = vhostWiki wikiConfig wikiCfgPath;
  services.httpd.virtualHosts."${cmtWikiConfig.domain}" = vhostWiki cmtWikiConfig cmtWikiCfgPath;
}
