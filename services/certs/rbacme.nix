# Taken from https://github.com/NixOS/nixpkgs/pull/63613
# Also incoroporates patches from https://github.com/NixOS/nixpkgs/pull/63613#issuecomment-531471460
# TODO delete this when PR is merged, and switch usages of legoCerts to certs
{ config, lib, pkgs, ... }:
with lib;
let

  cfg = config.security.acme;
  directory = "/var/lib/acme";

  certOpts = { name, ... }: {
    options = {
      webroot = mkOption {
        type = types.str;
        example = "/var/lib/acme/acme-challenges";
        description = ''
          Where the webroot of the HTTP vhost is located.
          <filename>.well-known/acme-challenge/</filename> directory
          will be created below the webroot if it doesn't exist.
          <literal>http://example.org/.well-known/acme-challenge/</literal> must also
          be available (notice unencrypted HTTP).
        '';
      };

      domain = mkOption {
        type = types.str;
        default = name;
        description = "Domain to fetch certificate for (defaults to the entry name)";
      };

      email = mkOption {
        type = types.str;
        description = "Contact email address for the CA to be able to reach you.";
      };

      user = mkOption {
        type = types.str;
        default = "root";
        description = "User running the ACME client.";
      };

      group = mkOption {
        type = types.str;
        default = "root";
        description = "Group running the ACME client.";
      };

      allowKeysForGroup = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Give read permissions to the specified group
          (<option>security.acme.cert.&lt;name&gt;.group</option>) to read SSL private certificates.
        '';
      };

      postRun = mkOption {
        type = types.lines;
        default = "";
        example = "systemctl reload nginx.service";
        description = ''
          Commands to run after new certificates go live. Typically
          the web server and other servers using certificates need to
          be reloaded.
          Executed in the same directory with the new certificate.
        '';
      };

      activationDelay = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Systemd time span expression to delay copying new certificates to main
          state directory. See <citerefentry><refentrytitle>systemd.time</refentrytitle>
          <manvolnum>7</manvolnum></citerefentry>.
        '';
      };

      preDelay = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Commands to run after certificates are re-issued but before they are
          activated. Typically the new certificate is published to DNS.
          Executed in the same directory with the new certificate.
        '';
      };

      extraDomains = mkOption {
        type = types.attrsOf (types.nullOr types.str);
        default = {};
        example = literalExample ''
          {
            "example.org" = "/srv/http/nginx";
            "mydomain.org" = null;
          }
        '';
        description = ''
          A list of extra domain names, which are included in the one certificate to be issued, with their
          own server roots if needed.
        '';
      };

      dnsProvider = mkOption {
        type = types.nullOr types.str;
        example = "route53";
        default = null;
        description = "DNS Challenge provider";
      };

      credentialsFile = mkOption {
        type = types.str;
        description = ''
          File containing DNS provider credentials passed as environment variables.
          See https://go-acme.github.io/lego/dns/ for more information.
        '';
        example = "/var/src/secrets/example.org-route53-api-token";
      };

      extraFlags = mkOption {
        type = types.listOf types.str;
        example = "[ \"--dns.disable-cp\" ]";
        default = [];
        description = "Extra flags to LEGo";
      };
    };
  };

in {
  ###### interface

  options.security.acme = {
    legoCerts = mkOption {
      default = { };
      type =  with types; attrsOf (submodule certOpts);
      description = ''
        Attribute set of certificates to get signed and renewed by LEGo.
      '';
      example = options.security.acme.certs.example;
    };
  };

  ###### implementation
  config = mkMerge [
    (mkIf (cfg.legoCerts != { }) {

      systemd.services = let
          services = concatLists servicesLists;
          servicesLists = mapAttrsToList certToServices cfg.legoCerts;
          certToServices = cert: data:
              let
                cpath = lpath + optionalString (data.activationDelay != null) ".staging";
                lpath = "${directory}/${cert}";
                rights = if data.allowKeysForGroup then "750" else "700";
                renewHook = pkgs.writeScript "lego-renew-hook" ''
                  touch ${cpath}/renewed
                '';
                globalOpts = optionals (cfg.server != null) ["--server" cfg.server]
                          ++ concatLists (mapAttrsToList (name: root: [ "--domains" name ]) data.extraDomains)
                          ++ [ "--domains" data.domain "--email" data.email "--accept-tos" ]
                          ++ (if data.dnsProvider != null then [ "--dns" data.dnsProvider ] else [ "--http.webroot" data.webroot ])
                          ++ data.extraFlags;
                renewOpts = [ "renew" "--renew-hook" renewHook "--days" (toString cfg.validMin) ];
                acmeService = {
                  description = "Renew ACME Certificate for ${cert}";
                  after = [ "network.target" "network-online.target" ];
                  wants = [ "network-online.target" ];
                  serviceConfig = {
                    Type = "oneshot";
                    SuccessExitStatus = [ "0" "1" ];
                    PermissionsStartOnly = true;
                    User = data.user;
                    Group = data.group;
                    PrivateTmp = true;
                    EnvironmentFile = data.credentialsFile;
                  };
                  path = with pkgs; [ lego systemd ];
                  preStart = ''
                    mkdir -p '${directory}'
                    chown 'root:root' '${directory}'
                    chmod 755 '${directory}'
                    if [ ! -d '${cpath}' ]; then
                      mkdir '${cpath}'
                    fi
                    chmod ${rights} '${cpath}'
                    chown -R '${data.user}:${data.group}' '${cpath}'
                    ${optionalString (data.dnsProvider == null) ''
                      mkdir -p '${data.webroot}/.well-known/acme-challenge'
                      chown -R '${data.user}:${data.group}' '${data.webroot}/.well-known/acme-challenge'
                    ''}
                    if [ -e ${cpath}/renewed ]; then
                        rm ${cpath}/renewed
                    fi
                  '';
                  script = ''
                    cd '${cpath}'
                    set +e
                    lego ${escapeShellArgs (globalOpts ++ renewOpts)}
                    EXITCODE=$?
                    set -e
                    if [ "$EXITCODE" != "0" ]; then
                      echo "initial lego certificate query"
                      lego ${escapeShellArgs (globalOpts ++ [ "run" ])} && ${renewHook}
                    fi
                  '';
                  postStop = ''
                    cd '${cpath}'

                    if [ -e ${cpath}/renewed ]; then
                      cp .lego/certificates/*${data.domain}.crt cert.pem
                      cp .lego/certificates/*${data.domain}.issuer.crt chain.pem
                      cp .lego/certificates/*${data.domain}.key key.pem
                      cat .lego/certificates/*${data.domain}.crt .lego/certificates/*${data.domain}.issuer.crt > fullchain.pem
                      cat .lego/certificates/*${data.domain}.key .lego/certificates/*${data.domain}.crt .lego/certificates/*${data.domain}.issuer.crt > full.pem
                      chmod ${rights} "${cpath}/"{key,fullchain,full,chain,cert}.pem
                      chown '${data.user}:${data.group}' "${cpath}/"{key,fullchain,full,chain,cert}.pem

                      ${if data.activationDelay != null then ''

                      ${data.preDelay}

                      if [ -d '${lpath}' ]; then
                        systemd-run --no-block --on-active='${data.activationDelay}' --unit acme-setlive-${cert}.service
                      else
                        systemctl --wait start acme-setlive-${cert}.service
                      fi
                      '' else data.postRun}

                      # noop ensuring that the "if" block is non-empty even if
                      # activationDelay == null and postRun == ""
                      true
                    fi
                    exit 0
                  '';

                  before = [ "acme-certificates.target" ];
                  wantedBy = [ "acme-certificates.target" ];
                };
                delayService = {
                  description = "Set certificate for ${cert} live";
                  path = with pkgs; [ rsync ];
                  serviceConfig = {
                    Type = "oneshot";
                  };
                  script = ''
                    rsync -a --delete-after '${cpath}/' '${lpath}'
                  '';
                  postStop = data.postRun;
                };
                selfsignedService = {
                  description = "Create preliminary self-signed certificate for ${cert}";
                  path = [ pkgs.openssl ];
                  preStart = ''
                      if [ ! -d '${cpath}' ]
                      then
                        mkdir -p '${cpath}'
                        chmod ${rights} '${cpath}'
                        chown '${data.user}:${data.group}' '${cpath}'
                      fi
                  '';
                  script =
                    ''
                      workdir="$(mktemp -d)"

                      # Create CA
                      openssl genrsa -des3 -passout pass:xxxx -out $workdir/ca.pass.key 2048
                      openssl rsa -passin pass:xxxx -in $workdir/ca.pass.key -out $workdir/ca.key
                      openssl req -new -key $workdir/ca.key -out $workdir/ca.csr \
                        -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=Security Department/CN=example.com"
                      openssl x509 -req -days 1 -in $workdir/ca.csr -signkey $workdir/ca.key -out $workdir/ca.crt

                      # Create key
                      openssl genrsa -des3 -passout pass:xxxx -out $workdir/server.pass.key 2048
                      openssl rsa -passin pass:xxxx -in $workdir/server.pass.key -out $workdir/server.key
                      openssl req -new -key $workdir/server.key -out $workdir/server.csr \
                        -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=IT Department/CN=example.com"
                      openssl x509 -req -days 1 -in $workdir/server.csr -CA $workdir/ca.crt \
                        -CAkey $workdir/ca.key -CAserial $workdir/ca.srl -CAcreateserial \
                        -out $workdir/server.crt

                      # Copy key to destination
                      cp $workdir/server.key ${cpath}/key.pem

                      # Create fullchain.pem (same format as "simp_le ... -f fullchain.pem" creates)
                      cat $workdir/{server.crt,ca.crt} > "${cpath}/fullchain.pem"

                      # Create full.pem for e.g. lighttpd
                      cat $workdir/{server.key,server.crt,ca.crt} > "${cpath}/full.pem"

                      # Give key acme permissions
                      chown '${data.user}:${data.group}' "${cpath}/"{key,fullchain,full}.pem
                      chmod ${rights} "${cpath}/"{key,fullchain,full}.pem
                    '';
                  serviceConfig = {
                    Type = "oneshot";
                    PermissionsStartOnly = true;
                    PrivateTmp = true;
                    User = data.user;
                    Group = data.group;
                  };
                  unitConfig = {
                    # Do not create self-signed key when key already exists
                    ConditionPathExists = "!${cpath}/key.pem";
                  };
                  before = [
                    "acme-selfsigned-certificates.target"
                  ];
                  wantedBy = [
                    "acme-selfsigned-certificates.target"
                  ];
                };
              in (
                [ { name = "acme-${cert}"; value = acmeService; } ]
                ++ optional cfg.preliminarySelfsigned { name = "acme-selfsigned-${cert}"; value = selfsignedService; }
                ++ optional (data.activationDelay != null) { name = "acme-setlive-${cert}"; value = delayService; }
              );
          servicesAttr = listToAttrs services;
          injectServiceDep = {
            after = [ "acme-selfsigned-certificates.target" ];
            wants = [ "acme-selfsigned-certificates.target" "acme-certificates.target" ];
          };
        in
          servicesAttr //
          (if config.services.nginx.enable then { nginx = injectServiceDep; } else {}) //
          (if config.services.lighttpd.enable then { lighttpd = injectServiceDep; } else {});

      systemd.timers = flip mapAttrs' cfg.legoCerts (cert: data: nameValuePair
        ("acme-${cert}")
        ({
          description = "Renew ACME Certificate for ${cert}";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = cfg.renewInterval;
            Unit = "acme-${cert}.service";
            Persistent = "yes";
            AccuracySec = "5m";
            RandomizedDelaySec = "1h";
          };
        })
      );

      systemd.targets."acme-selfsigned-certificates" = mkIf cfg.preliminarySelfsigned {};
      systemd.targets."acme-certificates" = {};
    })

  ];
}
