{config, pkgs, ...}:
let
  tld = config.redbrick.tld;

  common = import ../../common/variables.nix;

  sieveConfig = import ./sieve.nix { inherit pkgs; };
  authConfig = import ./auth.nix { inherit common pkgs tld; };
  masterConfig = import ./master.nix { inherit pkgs; };

  # Fixed uid + gid so that the config can roam systems safely
  vmailId = 975;

  # Fix mtime comparison so that scripts can be precompiled
  # See https://github.com/NixOS/nixpkgs/pull/35536/files
  # and https://github.com/dovecot/pigeonhole/pull/4
  pigeonhole = pkgs.dovecot_pigeonhole.overrideAttrs (old: {
    patches = [
      (pkgs.fetchpatch {
        name = "binary-mtime.patch";
        url = https://github.com/dovecot/pigeonhole/commit/3defbec146e195edad336a2c218f108462b0abd7.patch;
        sha256 = "09mvdw8gjzq9s2l759dz4aj9man8q1akvllsq2j1xa2qmwjfxarp";
      })
    ];
  });

in {
  networking.firewall.allowedTCPPorts = [ 993 ];

  security.dhparams.enable = true;
  # Name found in https://github.com/NixOS/nixpkgs/blob/d7752fc0ebf9d49dc47c70ce4e674df024a82cfa/nixos/modules/services/mail/dovecot.nix#L26
  security.dhparams.params.dovecot2.bits = 2048;

  # Create the user + group that will own /var/mail
  # Uid not actually used. If the year is 2021 and this config is in production
  # you can remove uid=uid from user_attrs in auth.nix and simplify the perms
  # in /var/mail. Read the blog post for more info
  users.users.vmail = {
    description = "Owns mail written by dovecot2";
    isSystemUser = true;
    group = "vmail";
    shell = "/dev/null";
    home = "/dev/null";
    uid = vmailId;
  };
  users.groups.vmail.gid = vmailId;

  # Increase ulimit due to service_auth client_limit (2000)
  systemd.services.dovecot2.serviceConfig.LimitNOFILE = 2500;

  services.dovecot2 = {
    enable = true;
    modules = [ pigeonhole ];

    enableImap = true;
    enableLmtp = true;
    enablePAM = false;
    showPAMFailure = false;

    sslServerCert = "${common.certsDir}/${tld}/fullchain.pem";
    sslServerKey = "${common.certsDir}/${tld}/key.pem";
    sslCACert = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    # We don't want all members to be able to read other member's mail
    # Force a specific group
    createMailUser = false;
    mailUser = "vmail";
    mailGroup = "vmail";

    # ENSURE /var/mail IS CHMOD 3770
    # See https://wiki.dovecot.org/SharedMailboxes/Permissions
    mailLocation = "mdbox:/var/mail/%d/%n";

    mailboxes = [{
      name = "Junk";
      specialUse = "Junk";
    } {
      name = "Trash";
      specialUse = "Trash";
    } {
      name = "Sent";
      specialUse = "Sent";
    } {
      name = "Drafts";
      specialUse = "Drafts";
    }];

    extraConfig = ''
      # Having trouble? Try enabling these
      auth_verbose = no
      mail_debug = no

      namespace inbox {
        separator = /
        inbox = yes
      }

      protocol imap {
        # max IMAP connections per IP address
        mail_max_userip_connections = 50
        # imap_sieve will be used for spam training by rspamd
        mail_plugins = $mail_plugins imap_sieve
      }

      protocol lmtp {
        mail_fsync = optimized
        mail_plugins = $mail_plugins sieve
      }

      # require SSL for all non-localhost connections
      ssl = required

      # Only the mail user should be authorized to write mail

      mail_home = /var/mail/%d/%n
      mail_attachment_dir = /var/mail/attachments
      mail_attachment_min_size = 64k

      # When copying perms from /var/mail, use this group
      mail_access_groups = vmail

      # require modern crypto - taken from Mozilla's SSL recommendations page
      ssl_min_protocol = TLSv1.2
      ssl_cipher_list = ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256
      ssl_prefer_server_ciphers = yes

      # Use a longer IDLE interval to reduce network chatter and save battery
      # life. Max is 30 minutes.
      imap_idle_notify_interval = 29 mins

      !include ${authConfig}
      !include ${masterConfig}

      # Enable sieve scripts
      protocols = $protocols sieve

      !include ${sieveConfig}
    '';
  };
}
