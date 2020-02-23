# Requires rspamadm dkim_keygen -k /var/secrets/${tld}.$(hostname).dkim.key -b 2048 -s $(hostname) -d ${tld}
# chown rspamd:root chmod 400
{config, pkgs, ...}:
let
  tld = config.redbrick.tld;
  common = import ../../common/variables.nix;

  ldapCommon = ''
    server_host = ldap://${common.ldapHost}/
    version = 3
    bind = no
  '';

  ldapAliasMap = pkgs.writeText "virt-mailbox-maps" (ldapCommon + ''
    search_base = ou=accounts,o=redbrick
    query_filter = (&(objectClass=posixAccount)(uid=%u))
    result_attribute = uid
    result_format = %s@${tld}
  '');

  commonRestrictions = [
    "permit_mynetworks" "permit_sasl_authenticated"
    "reject_unauth_pipelining"
  ];
in {
  imports = [
    ./postsrsd.nix
  ];

  # Ensure postsrsd is started before postfix
  systemd.services.postfix = {
    requires = [ "postsrsd.service" ];
    after = [ "postsrsd.service" ];
  };

  networking.firewall.allowedTCPPorts = [ 25 587 ];

  security.dhparams.enable = true;
  security.dhparams.params.smtpd_512.bits = 512;
  security.dhparams.params.smtpd_2048.bits = 2048;

  services.postfix = {
    enable = true;
    setSendmail = true;
    origin = tld;
    hostname = "mail.${tld}";
    destination = [tld "localhost"];
    recipientDelimiter = "+";

    sslCert = "${common.certsDir}/${tld}/fullchain.pem";
    sslKey = "${common.certsDir}/${tld}/key.pem";
    sslCACert = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    # disable authentication on port 25. This port should only be used by other
    # mail servers
    enableSubmission = true;
    submissionOptions = {
      smtpd_tls_security_level = "encrypt";
      tls_preempt_cipherlist = "yes";
    };

    # on the authenticated submission port, force TLS and use our more secure
    # cipher list
    # smtp_inet found in https://github.com/NixOS/nixpkgs/blob/54361cde9226ae6346b53b34acea9b493f803509/nixos/modules/services/mail/postfix.nix#L768
    masterConfig.smtp_inet.args = [ "-o" "smtpd_sasl_auth_enable=no" ];

    config = {
      # IP address used by postfix to send outgoing mail. You only need this if
      # your machine has multiple IP addresses - set it to your MX address to
      # satisfy your SPF record.
      smtp_bind_address = "192.168.0.135";
      # http://www.postfix.org/BASIC_CONFIGURATION_README.html#proxy_interfaces
      proxy_interfaces = "136.206.15.5";

      #virtual_mailbox_domains = tld;
      #virtual_mailbox_maps = "hash:/var/lib/postfix/aliases";
      #virtual_alias_maps = "ldap:" ++ ./ldap-virtual-alias-maps.cf;
      # alias_maps = "hash:/etc/aliases, ldap:";

      # Generate own DHParams
      smtpd_tls_dh512_param_file = config.security.dhparams.params.smtpd_512.path;
      smtpd_tls_dh1024_param_file = config.security.dhparams.params.smtpd_2048.path;

      # enable SMTPD auth. Dovecot will place an `auth` socket in postfix's
      # runtime directory that we will use for authentication.
      # https://wiki.dovecot.org/HowTo/PostfixAndDovecotSASL
      smtpd_sasl_auth_enable = true;
      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "inet:${common.dovecotHost}:${builtins.toString common.dovecotSaslPort}";

      # deliver mail for virtual users to Dovecot's TCP socket
      # http://www.postfix.org/lmtp.8.html
      mailbox_transport = "lmtp:inet:${common.dovecotHost}:${builtins.toString common.dovecotLmtpPort}";

      # Configure postsrsd so that forwarded mail is "remailed" with a safe from address
      sender_canonical_maps = "tcp:127.0.0.1:${builtins.toString config.services.postsrsd.forwardPort}";
      recipient_canonical_maps = "tcp:127.0.0.1:${builtins.toString config.services.postsrsd.reversePort}";
      sender_canonical_classes = "envelope_sender";
      recipient_canonical_classes = "envelope_recipient";

      # cache incoming and outgoing TLS sessions
      smtpd_tls_session_cache_database = "btree:/var/lib/postfix/data/smtpd_tlscache";
      smtp_tls_session_cache_database  = "btree:/var/lib/postfix/data/smtp_tlscache";

      # These two lines define how postfix will connect to other mail servers.
      # DANE is a stronger form of opportunistic TLS. You can read about it here:
      # http://www.postfix.org/TLS_README.html#client_tls_dane
      #smtp_tls_security_level = dane
      #smtp_dns_support_level = dnssec
      # DANE requires a DNSSEC capable resolver. If your DNS resolver doesn't
      # support DNSSEC, remove the above two lines and uncomment the below:
      smtp_tls_security_level = "may";

      # Here we define the options for "mandatory" TLS. In our setup, TLS is only
      # "mandatory" for authenticating users. I got these settings from Mozilla's
      # SSL reccomentations page.
      #
      # NOTE: do not attempt to make TLS mandatory for all incoming/outgoing
      # connections. Do not attempt to change the default cipherlist for non-
      # mandatory connections either. There are still a lot of mail servers out
      # there that do not use TLS, and many that do only support old ciphers.
      # Forcing TLS for everyone *will* cause you to lose mail.
      smtpd_tls_mandatory_protocols = "!SSLv2, !SSLv3, !TLSv1, !TLSv1.1, TLSv1.2";
      smtpd_tls_mandatory_ciphers = "high";
      tls_high_cipherlist = "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256";

      # disable "new mail" notifications for local unix users
      biff = false;

      # limit maximum e-mail size to 25MB. mailbox size must be at least as big as
      # the message size for the mail to be accepted, but has no meaning after
      # that since we are using Dovecot for delivery.
      message_size_limit = "25600000";
      mailbox_size_limit = "25600000";

      # prevent spammers from searching for valid users
      disable_vrfy_command = true;

      # don't give any helpful info when a mailbox doesn't exist
      show_user_unknown_table_name = false;

      # require addresses of the form "user@domain.tld"
      allow_percent_hack = false;
      swap_bangpath = false;

      # We'll uncomment these when we set up rspamd later:
      # milter_protocol = 6
      # milter_default_action = accept
      # smtpd_milters = unix:/var/run/rspamd/milter.sock
      # milter_mail_macros = i {mail_addr} {client_addr} {client_name} {auth_authen}

      # tickets and compression have known vulnerabilities
      tls_ssl_options = "no_ticket, no_compression";

      # only allow authentication over TLS
      smtpd_tls_auth_only = true;

      # require properly formatted email addresses - prevents a lot of spam
      strict_rfc821_envelopes = true;

      # don't allow plaintext auth methods on unencrypted connections
      smtpd_sasl_security_options = "noanonymous, noplaintext";
      # but plaintext auth is fine when using TLS
      smtpd_sasl_tls_security_options = "noanonymous";

      # add a message header when email was recieved over TLS
      smtpd_tls_received_header = true;

      # require that connecting mail servers identify themselves - this greatly
      # reduces spam
      smtpd_helo_required = true;

      smtpd_helo_restrictions = builtins.concatStringsSep ", " (commonRestrictions ++ [
        "reject_invalid_helo_hostname" "reject_non_fqdn_helo_hostname"
        # This will reject all incoming mail without a HELO hostname that
        # properly resolves in DNS. This is a somewhat restrictive check and may
        # reject legitimate mail.
        "reject_unknown_helo_hostname"
      ]);
      smtpd_sender_restrictions = builtins.concatStringsSep ", " (commonRestrictions ++ [
        "reject_non_fqdn_sender" "reject_unknown_sender_domain"
      ]);
      smtpd_recipient_restrictions = builtins.concatStringsSep ", " (commonRestrictions ++ [
        "reject_non_fqdn_recipient" "reject_unknown_recipient_domain"
        "reject_unverified_recipient"
      ]);
      smtpd_data_restrictions = builtins.concatStringsSep ", " (commonRestrictions ++ [
        "reject_multi_recipient_bounce"
      ]);
      smtpd_relay_restrictions = builtins.concatStringsSep ", " [
        "permit_mynetworks" "permit_sasl_authenticated"
        # !!! THIS SETTING PREVENTS YOU FROM BEING AN OPEN RELAY !!!
        "reject_unauth_destination"
        # !!!      DO NOT REMOVE IT UNDER ANY CIRCUMSTANCES      !!!
      ];
    };

    # Sets smtpd_client_restrictions
    dnsBlacklists = commonRestrictions ++ [
      "reject_unknown_reverse_client_hostname"
      # This will reject all incoming connections without a reverse DNS
      # entry that resolves back to the client's IP address. This is a very
      # restrictive check and may reject legitimate mail.
      "reject_unknown_client_hostname"
    ];
  };

  # Enable rspamd and connect to postfix.
  services.rspamd = {
    enable = true;
    postfix.enable = true;
    locals."dkim_signing.conf".text = ''
      path = "/var/secrets/$domain.$selector.dkim.key";
      selector = "${config.networking.hostName}";
      allow_username_mismatch = true;
    '';
  };
}
