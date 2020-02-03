{ tld }:
let
  common = import ../../common/variables.nix;

  webtree = common.webtreeDir;
  home = common.homesDir;
  adminAddr = "webmaster@${tld}";
in {
  inherit common webtree home tld adminAddr;

  vhost = {user, group, hostName, documentRoot, serverAliases ? [ "www.${hostName}" ], extraConfig ? "", wwwCert ? false}: let

    # Figure out from the hostName whether there is a custom cert for this domain
    # This could be simplified if config.services.legoAcme could be queried for domains
    theirTld = if wwwCert then hostName else common.domainTld hostName;
    isOurTld = ((builtins.match ".*\\.${tld}" hostName) != null) || ((builtins.match ".*\\.dcu\\.ie" hostName) != null);

    sslConfig = if !isOurTld then {
      sslServerKey = "${common.certsDir}/${theirTld}/key.pem";
      sslServerCert = "${common.certsDir}/${theirTld}/fullchain.pem";
    } else {};
  in {
    inherit hostName documentRoot serverAliases;
    adminAddr = "${if user == "wwwrun" then "webmaster" else user}@${tld}";
    enableSSL = true;
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
    '';
  } // sslConfig;

  vhostRedirect = hostName: globalRedirect: {
    inherit hostName adminAddr;
    globalRedirect = "${globalRedirect}/";
    enableSSL = true;
    serverAliases = [];
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
