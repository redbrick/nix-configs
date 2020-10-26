{stdenv, config, lib, pkgs, buildGoPackage, ...}:
with lib;
let
  tld = config.redbrick.tld;
  configPath = "/etc/inspircd/inspircd.conf";
  package = import ../../packages/inspircd { inherit pkgs; };
  attrToConfig = import ./config.nix { inherit lib; };
  inspircdConf = import ./inspircd_conf.nix { inherit config lib; };
  configFile = pkgs.writeText "inspircd.conf" (attrToConfig inspircdConf);
  goDiscordIrcPkg = import ../../packages/go-discord-irc {
    inherit pkgs stdenv buildGoPackage;
  };
  discordConf = import ./discord_conf.nix { inherit config lib; };
  discordConfFile = pkgs.writeText "discord.yaml" (builtins.toJSON discordConf);
in {
  environment.etc."inspircd/inspircd.conf" = { source = configFile; };
  security.dhparams.enable = true;
  security.dhparams.params.ircd.bits = 2048;
  security.acme.acceptTerms = true;
  security.acme.certs = {
    "irc.${tld}" = {
      email = "webmaster+acme@${tld}";
      dnsProvider = "rfc2136";
      credentialsFile = "/var/secrets/certs.secret";
      dnsPropagationCheck = false;
      extraDomainNames = [ tld ];
      group = "inspircd";
    };
  };

  systemd.services."acme-irc.${tld}".environment = let
    proxy = config.networking.proxy.default;
  in {
    http_proxy = proxy;
    https_proxy = proxy;
    HTTP_PROXY = proxy;
    HTTPS_PROXY = proxy;
  };

  users.groups.inspircd = {};
  users.users.inspircd = {
    uid = 320;
    group = "inspircd";
    description = "inspircd daemon user";
  };

  systemd.services.inspircd = {
    description = "inspircd service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    stopIfChanged = false;

    serviceConfig = {
      ExecStart = "${package}/bin/inspircd --nofork --nopid --config ${configPath}";
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      User = "inspircd";
      Restart = "always";
      RestartSec = "10s";
    };

    unitConfig.Documentation = "man:inspircd(8)";
  };

  # inspired by https://github.com/NixOS/nixpkgs/blob/d7e569657406f6bb57e29b64d6a5044ddc0d844e/nixos/modules/services/web-servers/nginx/default.nix#L749
  systemd.services.inspircd-config-reload = {
    wants = [ "inspircd.service" ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ configFile ];
    serviceConfig.Type = "oneshot";
    serviceConfig.TimeoutSec = 60;
    script = ''
      if /run/current-system/systemd/bin/systemctl -q is-active inspircd.service ; then
        /run/current-system/systemd/bin/systemctl reload inspircd.service
      fi
    '';
    serviceConfig.RemainAfterExit = true;
  };
  networking.firewall.allowedTCPPorts = [ 6697 7001 ];


  systemd.services.go-discord-irc = {
    description = "Discord IRC Bridge Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    stopIfChanged = false;

    serviceConfig = {
      ExecStart = "${goDiscordIrcPkg}/go-discord-irc --config ${discordConfFile}";
      User = "inspircd";
      Restart = "always";
      RestartSec = "10s";
    };
  };

}
