# Manual steps post-deploy:
# cd /var/lib/mailman-web && sudo -u wwwrun mailman-web createsuperuser
{ pkgs, lib, config, ... }:
with (import ./shared.nix { tld = config.redbrick.tld; });
let
  webRoot = config.services.mailman.webRoot;
  generatedDataPath = "/var/lib/mailman-web";

  # Build mod_wsgi with python3
  wsgiPkg = with pkgs; mod_wsgi.overrideAttrs (oldAttrs: {
    buildInputs = [ apacheHttpd python3 ncurses ];
  });

  vhostConfig = {
    adminAddr = "webmaster@${tld}";
    serverAliases = [ "localmail.${tld}" ];
    servedDirs = [ { dir = "${generatedDataPath}/static"; urlPath = "/static"; } ];
    extraConfig = ''
      <Location /accounts/signup>
        Order allow,deny
        Deny from all
      </Location>
      <Directory "${webRoot}">
        Options ExecCGI
        <Files wsgi.py>
          Require all granted
        </Files>
        WSGIProcessGroup mailman
      </Directory>
      WSGIScriptAlias / ${webRoot}/mailman_web/wsgi.py
    '';
  };
in {
  services.httpd = {
    extraModules = [ { name = "wsgi"; path = "${wsgiPkg}/modules/mod_wsgi.so"; } ];
    extraConfig = ''
      WSGISocketPrefix /run/httpd/wsgi
      WSGIDaemonProcess mailman threads=4 home=${generatedDataPath} python-path=/etc/mailman3:${webRoot}:${
        lib.makeSearchPath pkgs.python3.sitePackages
          pkgs.python3Packages.mailman-web.requiredPythonModules
      }
    '';

    virtualHosts."lists.${tld}" = vhostConfig // { onlySSL = true; } // (vhostCerts tld);
  };
}
