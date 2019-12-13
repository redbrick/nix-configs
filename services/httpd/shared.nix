let
  common = import ../../common/variables.nix;

  webtree = common.webtreeDir;
  home = common.homesDir;
  tld = common.tld;
  adminAddr = "webmaster@${tld}";
in {
  inherit common webtree home tld adminAddr;

  vhost = hostName: documentRoot: {
    inherit hostName documentRoot adminAddr;
    enableSSL = true;
    serverAliases = [ "www.${hostName}" ];
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
