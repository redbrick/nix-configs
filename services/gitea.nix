{ config, lib, ... }:
let
  tld = config.redbrick.tld;

  secrets = import /var/secrets/gitea.nix;
  tokenPath = "/var/secrets/gitea_token.secret";

  stateDir = "/var/lib/gitea";
  repositoryRoot = "/zroot/git";
in {
  users.users.git = {
    description = "Service user for gitea";
    isSystemUser = true;
    group = "gitea";
    shell = "/dev/null";
    home = "/dev/null";
  };

  systemd.services.gitea.serviceConfig.SystemCallFilter =
    lib.mkForce "~@clock @cpu-emulation @debug @keyring @memlock @module @mount @obsolete @raw-io @reboot @resources @setuid @swap";
  systemd.services.gitea.serviceConfig.ReadWritePaths = lib.mkForce "${stateDir} ${repositoryRoot} /var/secrets";

  services.gitea = {
    inherit stateDir repositoryRoot;
    enable = true;
    appName = "Redbrick";
    user = "git";
    domain = tld;
    httpPort = 3000;
    rootUrl = "https://git.${tld}/";

    database = {
      createDatabase = false;
      type = "postgres";
      host = "localhost";
      port = 5432;
      user = "gitea";
      name = "gitea";
      passwordFile = "/var/secrets/giteadb.secret";
    };

    extraConfig = ''
      [repository.upload]
      TEMP_PATH = ${stateDir}/uploads

      [server]
      SSH_DOMAIN       = git.${tld}
      DISABLE_SSH      = true
      SSH_PORT         = 10022
      LFS_START_SERVER = false
      OFFLINE_MODE     = false

      [session]
      PROVIDER_CONFIG = ${stateDir}/sessions
      PROVIDER        = file

      [picture]
      AVATAR_UPLOAD_PATH      = ${stateDir}/avatars
      DISABLE_GRAVATAR        = false
      ENABLE_FEDERATED_AVATAR = false

      [attachment]
      PATH = ${stateDir}/attachments

      [mailer]
      ENABLED = true
      HOST    = mailhost.redbrick.dcu.ie:587
      FROM    = gitea@redbrick.dcu.ie

      [service]
      REGISTER_EMAIL_CONFIRM     = false
      ENABLE_NOTIFY_MAIL         = true
      DISABLE_REGISTRATION       = true
      ENABLE_CAPTCHA             = false
      REQUIRE_SIGNIN_VIEW        = false
      DEFAULT_KEEP_EMAIL_PRIVATE = false
      NO_REPLY_ADDRESS           = noreply.redbrick.dcu.ie

      [security]
      INSTALL_LOCK   = true
      SECRET_KEY     = ${secrets.secret_key}
      INTERNAL_TOKEN_URI = file:${tokenPath}

      [openid]
      ENABLE_OPENID_SIGNUP = false
      ENABLE_OPENID_SIGNIN = false

      [metrics]
      ENABLED = true
      [log.console]
      COLORIZE = false
    '';
  };
}
