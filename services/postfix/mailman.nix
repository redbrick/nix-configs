# Manual steps post-deploy:
# cd /var/lib/mailman && sudo -u mailman mailman aliases && systemctl restart postfix
{pkgs, config, lib, ...}:
let
  common = import ../../common/variables.nix;

  tld = config.redbrick.tld;
  secretsFile = "/var/secrets/mailman.json";
  secrets = import /var/secrets/mailman.nix;
  postgresHost = "127.0.0.1";

  mailServer = "localmail.${tld}";

  # Mailman needs access to hyperkitty, which is on the same host
  hyperkittyLocal = mailServer;

  # We have some custom overrides in settings.py which means we need to generate this ourselves
  webSettingsJSON = pkgs.writeText "settings.json" (builtins.toJSON config.services.mailman.webSettings);
in {
  services.mailman = rec {
    enable = true;
    siteOwner = "admins+mailman@${tld}";
    webHosts = [ "lists.${tld}" "localmail.${tld}" ];
    hyperkitty = {
      enable = true;
      baseUrl = "https://${hyperkittyLocal}/hyperkitty/";
    };
    extraPythonPackages = with pkgs.python3Packages; [ ldap pyasn1-modules django-auth-ldap ];
    webSettings = {
      # When initialising Mailman, comment this line out until you go to /admin and add a site
      # Otherwise you might get "Site matching query does not exist"
      SITE_ID = 2;

      # Basic settings. Most of these are actually in the Nix module, but we can't merge with
      # those unfortunately.
      TIME_ZONE = "Europe/Dublin";
      DEFAULT_FROM_EMAIL = "mailmgr@${tld}";
      SERVER_EMAIL = "mailmgr@${tld}";
      ALLOWED_HOSTS = [ "localhost" "127.0.0.1" ] ++ webHosts;
      COMPRESS_OFFLINE = true;
      STATIC_ROOT = "/var/lib/mailman-web-static";
      MEDIA_ROOT = "/var/lib/mailman-web/media";
      LOGGING = {
        version = 1;
        disable_existing_loggers = true;
        handlers.console.class = "logging.StreamHandler";
        loggers.django = {
          handlers = [ "console" ];
          level = "INFO";
        };
      };
      HAYSTACK_CONNECTIONS.default = {
        ENGINE = "haystack.backends.whoosh_backend.WhooshEngine";
        PATH = "/var/lib/mailman-web/fulltext-index";
      };

      # Auth settings
      ACCOUNT_EMAIL_VERIFICATION = "none";
      AUTHENTICATION_BACKENDS = [
        "django_auth_ldap.backend.LDAPBackend"
        "django.contrib.auth.backends.ModelBackend"
      ];
      # Use the user's own credentials to bind to LDAP. Allows for reading of
      # special fields, and no need for a mailman LDAP user
      AUTH_LDAP_SERVER_URI = "ldap://${common.ldapHost}";
      AUTH_LDAP_BIND_AS_AUTHENTICATING_USER = true;
      AUTH_LDAP_USER_ATTRLIST = ["*" "+"];
      AUTH_LDAP_USER_DN_TEMPLATE = "uid=%(user)s,ou=accounts,o=redbrick";
      AUTH_LDAP_USER_ATTR_MAP = {
        username = "uid";
        first_name = "cn";
      };
      AUTH_LDAP_MIRROR_GROUPS = true;
      AUTH_LDAP_USER_FLAGS_BY_GROUP = {
        is_superuser = "cn=mailadm,ou=groups,o=redbrick";
      };
    };
  };

  # Mailman core has no real NixOS Options
  # Extend the etc file..
  environment.etc."mailman.cfg" = {
    mode = "0400";
    user = "mailman";
    text = ''
      [mta]
      smtp_host: ${mailServer}
      smtp_port: 587
      smtp_user: ${secrets.emailUser}
      smtp_pass: ${secrets.emailPassword}
      smtp_secure_mode: starttls
      remove_dkim_headers: yes
      
      [database]
      class: mailman.database.postgresql.PostgreSQLDatabase
      url: postgresql://${secrets.dbUser}:${secrets.dbPassword}@localhost/migrated_mailman
    '';
  };

  # Our ldap has combined first name + last name (cn), and no email field
  # If there's ever a Django dev looking at this and sees a better way to do it,
  # PLEASE DO IT
  environment.etc."mailman3/rbapp/__init__.py".text = ''
    __version__ = '1.0.0'
    default_app_config = 'rbapp.apps.RBAppConfig'
  '';
  environment.etc."mailman3/rbapp/signals.py".text = ''
    from django_auth_ldap.backend import populate_user
    from django.dispatch import receiver

    @receiver(populate_user)
    def on_populate_user(sender, **kwargs):
        """Process population of a user."""
        user = kwargs.get('user', None)
        ldap_user = kwargs.get('ldap_user', None)

        if not (user and ldap_user):
            return

        user.email = user.username + "@${tld}"

        name_split = user.first_name.split()
        if len(name_split) != 2:
          return

        first_name, last_name = name_split
        user.first_name = first_name
        user.last_name = last_name
  '';
  environment.etc."mailman3/rbapp/apps.py".text = ''
    from django.apps import AppConfig

    class RBAppConfig(AppConfig):
        name = 'rbapp'
        verbose_name = 'RB App'

        def ready(self):
            import rbapp.signals
  '';
  environment.etc."mailman3/settings.py".text = ''
    import json
    import os

    # Required by mailman_web.settings, but will be overridden when
    # settings_local.json is loaded.
    os.environ["SECRET_KEY"] = ""

    from mailman_web.settings import *

    with open('${webSettingsJSON}') as f:
        globals().update(json.load(f))

    with open('/var/lib/mailman-web/settings_local.json') as f:
        globals().update(json.load(f))

    import ldap
    from django_auth_ldap.config import LDAPSearch, PosixGroupType

    AUTH_LDAP_GROUP_TYPE = PosixGroupType()
    AUTH_LDAP_USER_SEARCH = LDAPSearch("ou=accounts,o=redbrick", ldap.SCOPE_SUBTREE, "(uid=%(user)s)")
    AUTH_LDAP_GROUP_SEARCH = LDAPSearch("ou=groups,o=redbrick", ldap.SCOPE_SUBTREE, "(objectClass=posixGroup)")

    with open('${secretsFile}', 'r') as db_pass_file:
        secrets = json.load(db_pass_file)

    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': 'mailman',
            'USER': secrets['db_user'],
            'PASSWORD': secrets['db_password'],
            'HOST': '${postgresHost}',
            'PORT': '5432',
        }
    }

    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    EMAIL_HOST = '${mailServer}'
    EMAIL_PORT = 587
    EMAIL_USE_TLS = True
    EMAIL_HOST_USER = secrets['email_user']
    EMAIL_HOST_PASSWORD = secrets['email_password']
  '';

  services.postfix = {
    relayDomains = [ "hash:/var/lib/mailman/data/postfix_domains" ];
    config.transport_maps = [ "hash:/var/lib/mailman/data/postfix_lmtp" ];
    config.local_recipient_maps = [ "hash:/var/lib/mailman/data/postfix_lmtp" ];
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
