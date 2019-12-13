let
  common = import ../../common/variables.nix;

  webtree = common.webtreeDir;
  home = common.homesDir;
  tld = common.tld;
  adminAddr = "webmaster@${tld}";
in {
  inherit common webtree home tld adminAddr;

  vhost = {user, group, hostName, documentRoot, serverAliases ? [ "www.${hostName}" ], extraConfig ? ""}: {
    inherit hostName documentRoot serverAliases;
    adminAddr = "${if user == "wwwrun" then "webmaster" else user}@${tld}";
    enableSSL = true;
    extraConfig = ''
      <Directory "${documentRoot}">
        <FilesMatch \.php\d*$>
          SetHandler "proxy:unix:/run/phpfpm/${user}.sock|fcgi://localhost/"
        </FilesMatch>

        AllowOverride AuthConfig FileInfo Indexes Limit AuthConfig Options=ExecCGI,Includes,IncludesNoExec,Indexes,MultiViews,SymlinksIfOwnerMatch NonFatal=Unknown
        Require all granted
      </Directory>

      SuExecUserGroup ${user} ${group}

      ${extraConfig}
    '';
  };

  vhostRedirect = hostName: globalRedirect: {
    inherit hostName globalRedirect adminAddr;
    enableSSL = true;
    serverAliases = [ "www.${hostName}" ];
  };

  vhostProxy = hostName: proxyAddress: {
    inherit hostName adminAddr;
    enableSSL = true;
    serverAliases = [ "www.${hostName}" ];
    extraConfig = ''
      <Proxy *>
        Order deny,allow
        Allow from all
      </Proxy>

      ProxyPass / ${proxyAddress}/
      ProxyPassReverse / ${proxyAddress}/
    '';
  };
}
