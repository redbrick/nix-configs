{config, pkgs, ...}:
let
  tld = config.redbrick.tld;

  common = import ../../common/variables.nix;

  commonDovecot = import ./variables.nix;

  vmailUserName = "vmail";

  authConfig = import ./auth.nix { inherit common pkgs vmailUserName; };
  masterConfig = import ./master.nix { inherit common pkgs; };
in {
  networking.firewall.allowedTCPPorts = [ 993 common.dovecotSaslPort common.dovecotLmtpPort ];

  security.dhparams.enable = true;
  # Name found in https://github.com/NixOS/nixpkgs/blob/d7752fc0ebf9d49dc47c70ce4e674df024a82cfa/nixos/modules/services/mail/dovecot.nix#L26
  security.dhparams.params.dovecot2.bits = 2048;

  services.dovecot2 = {
    enable = true;
    enableImap = true;
    enableLmtp = true;
    enablePAM = false;
    showPAMFailure = false;

    sslServerCert = "${common.certsDir}/${tld}/fullchain.pem";
    sslServerKey = "${common.certsDir}/${tld}/key.pem";
    sslCACert = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    # We don't want all members to be able to read other member's mail
    # Force a specific group
    mailGroup = vmailUserName;

    mailLocation = "mdbox:~/mdbox";

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
      # to improve performance, disable fsync globally - we will enable it for
      # some specific services later on
      mail_fsync = never

      auth_verbose = yes

      mail_debug = yes

      namespace inbox {
        separator = /
        inbox = yes
      }

      protocol imap {
        # max IMAP connections per IP address
        mail_max_userip_connections = 50
        # imap_sieve will be used for spam training by rspamd
        mail_plugins = $mail_plugins # imap_sieve
      }

      protocol lmtp {
        mail_fsync = optimized
        mail_plugins = $mail_plugins
      }

      # require SSL for all non-localhost connections
      ssl = required

      mail_home = /var/mail/%n
      mail_attachment_dir = /var/mail/attachments
      mail_attachment_min_size = 64k

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
      # protocols = $protocols sieve

      # plugin {
        # location of users' sieve directory and their "active" sieve script
        # sieve = file:~/sieve;active=~/.dovecot.sieve

        # directory of global sieve scripts to run before and after processing ALL
        # incoming mail
        # sieve_before = /usr/local/etc/dovecot/sieve-before.d
        # sieve_after  = /usr/local/etc/dovecot/sieve-after.d

        # make sieve aware of user+tag@domain.tld aliases
        # recipient_delimiter = +

        # maximum size of all user's sieve scripts
        # sieve_quota_max_storage = 10M
      # }
    '';
  };
}
