let
  common = import ../../common/variables.nix;

  webtree = common.webtreeDir;
  home = common.homesDir;
  tld = common.tld;
  adminAddr = "webmaster@${tld}";
in {
  inherit common webtree home tld adminAddr;

  vhost = {user, group, hostName, documentRoot, serverAliases ? [ "www.${hostName}" ]}: {
    inherit hostName documentRoot adminAddr serverAliases;
    enableSSL = true;
    extraConfig = ''
      <Directory "${documentRoot}">
        AllowOverride AuthConfig FileInfo Indexes Limit AuthConfig Options=ExecCGI,Includes,IncludesNoExec,Indexes,MultiViews,SymlinksIfOwnerMatch
        Require all granted
      </Directory>

      <FilesMatch \.php\d*$>
        SetHandler "proxy:unix:/run/phpfpm/${user}.sock|fcgi://localhost/"
      </FilesMatch>

      SuExecUserGroup ${user} ${group}
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
