let
  common = import ../common/variables.nix;

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

  services.gitea = {
    inherit stateDir repositoryRoot;
    enable = true;
    appName = "Redbrick";
    user = "git";
    domain = common.tld;
    httpPort = 3000;
    rootUrl = "https://git.${common.tld}/";

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
      SSH_DOMAIN       = git.redbrick.dcu.ie
      DISABLE_SSH      = false
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
      SECRET_KEY     = ZaAgYxsMt3
      INTERNAL_TOKEN = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYmYiOjE0OTI2MDcxMDR9.T3CCdLpGcXvOzC_Wg7Uq8fN-YE3TCJPofGmiHnaypUg

      [openid]
      ENABLE_OPENID_SIGNUP = false
      ENABLE_OPENID_SIGNIN = false

      [oauth2]
      JWT_SECRET = 0l4Md3fIHiSXRVK4gFpvO2CFXqhb8qSzWLuHPioWUyo

    '';
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}