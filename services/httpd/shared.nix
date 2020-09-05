{ tld }:
let
  common = import ../../common/variables.nix;

  webtree = common.webtreeDir;
  home = common.homesDir;
  adminAddr = "webmaster@${tld}";

  wwwRedirector = ''
    RedirectMatch 301 "^www\.(.*)$" "https://$1"
  '';
in {
  inherit common webtree home tld adminAddr;

  vhost = {user, group, documentRoot, serverAliases ? [],
            extraConfig ? "", wwwRedirect ? false}: {
    inherit documentRoot serverAliases;
    adminAddr = if user == "wwwrun" then adminAddr else "${user}@${tld}";
    onlySSL = true;
    extraConfig = ''
      <Directory "${documentRoot}">
        <FilesMatch \.php\d*$>
          SetHandler "proxy:unix:/run/phpfpm/${user}.sock|fcgi://localhost/"
        </FilesMatch>

        Options +Includes
        AllowOverride AuthConfig FileInfo Indexes Limit AuthConfig Options=ExecCGI,Includes,IncludesNoExec,Indexes,MultiViews,SymlinksIfOwnerMatch NonFatal=Unknown
        Require all granted
      </Directory>

      SuExecUserGroup ${user} ${group}

      ${extraConfig}
    '' + (if wwwRedirect then wwwRedirector else "");
  };

  vhostRedirect = globalRedirect: {
    inherit adminAddr globalRedirect;
    onlySSL = true;
  };

  vhostProxy = proxyAddress: {
    inherit adminAddr;
    onlySSL = true;
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
