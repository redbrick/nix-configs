# Requires rspamadm dkim_keygen -k /var/secrets/${tld}.$(hostname).dkim.key -b 2048 -s $(hostname) -d ${tld}
# chown rspamd:root chmod 400
{config, pkgs, lib, ...}:
let
  tld = config.redbrick.tld;
  common = import ../../common/variables.nix;

  aliases = import ./aliases.nix { inherit tld; };
  # TLD needs to be appended to use aliases as sender address with smtpd_sender_login_maps
  # Only supports 1:1 mappings but could be modified to support 1:Many
  aliasesAbsolute = lib.mapAttrs (alias: owner: if (builtins.match "^[a-zA-Z0-9_\\-\\+\\.]+$" owner) != null then "${owner}@${tld}" else owner) aliases;
  aliasesFile = pkgs.writeText "postfix-aliases" (builtins.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}: ${v}") aliasesAbsolute));

  ldapCommon = ''
    server_host = ldap://${common.ldapHost}/
    version = 3
    bind = no
    search_base = ou=accounts,o=redbrick
  '';

  # Authenticated users we always accept mail from over port 587
  # Allows mailman to spoof addresses
  sender_whitelist = pkgs.writeText "sender_whitelist" ''
    mailmgr@${tld} OK
  '';

  ldapSenderMap = pkgs.writeText "postfix-sender-maps" (ldapCommon + ''
    query_filter = (&(objectClass=posixAccount)(uid=%u))
    result_attribute = uid
    result_format = %s@${tld}
  '');

  # Addresses we reject mail from over port 25
  sender_blacklist = pkgs.writeText "sender_blacklist" ''
    ${tld} REJECT
  '';

  # IPs we reject unauthenticated connections from
  # Rspamd explicitly allows mail from local addresses which is dangerous for us
  # List taken from rspamd's local_addrs option
  unauth_ip_blacklist = pkgs.writeText "unauth_ip_blacklist" ''
    127.0.0.0/8     REJECT
    192.168.0.0/16  REJECT
    10.0.0.0/8      REJECT
    172.16.0.0/12   REJECT
    fd00::/8        REJECT
    169.254.0.0/16  REJECT
    fe80::/10       REJECT
  '';

  commonRestrictions = [
    "permit_sasl_authenticated"
    "reject_unauth_pipelining"
  ];
in {
  imports = [
    ../redis.nix
    ./mailman.nix
    ./rspamd.nix
    ./postsrsd.nix
  ];

  # Add postfix to redis group
  users.users.postfix.extraGroups = [
    "redis"
  ];

  # Ensure postsrsd is started before postfix
  systemd.services.postfix = {
    requires = [ "postsrsd.service" "redis.service" "rspamd.service" ];
    after = [ "postsrsd.service" "redis.service" "rspamd.service" ];
  };

  networking.firewall.allowedTCPPorts = [ 25 587 ];

  # Since the TLD cert is a wildcard, this allows us to use TLS
  # over localhost and authenticate correctly. Used in mailman
  networking.hosts."127.0.0.1" = [ "localmail.${tld}" ];

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

    # Files that need postmap run on them
    # Added to /var/lib/postfix/conf/<name>
    mapFiles.sender_whitelist = sender_whitelist;
    mapFiles.sender_blacklist = sender_blacklist;
    mapFiles.unauth_ip_blacklist = unauth_ip_blacklist;

    # Aliases
    aliasFiles.redbrick_aliases = aliasesFile;

    config = {
      # IP address used by postfix to send outgoing mail. You only need this if
      # your machine has multiple IP addresses - set it to your MX address to
      # satisfy your SPF record.
      smtp_bind_address = config.redbrick.smtpBindAddress;
      # http://www.postfix.org/BASIC_CONFIGURATION_README.html#proxy_interfaces
      proxy_interfaces = config.redbrick.smtpExternalAddress;

      # Some bad clients...like MAILMAN... forget to add some important headers
      # In particular I saw mailman forget Message-ID. This setting permits postfix
      # to fix them
      local_header_rewrite_clients = "permit_sasl_authenticated";

      # Generate own DHParams
      smtpd_tls_dh512_param_file = config.security.dhparams.params.smtpd_512.path;
      smtpd_tls_dh1024_param_file = config.security.dhparams.params.smtpd_2048.path;

      # enable SMTPD auth. Dovecot will place an `auth` socket in postfix's
      # runtime directory that we will use for authentication.
      # https://wiki.dovecot.org/HowTo/PostfixAndDovecotSASL
      smtpd_sasl_auth_enable = true;
      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "unix:/var/run/dovecot2_sasl.sock";

      # Deliver mail for all users to Dovecot's LMTP socket
      # http://www.postfix.org/lmtp.8.html
      mailbox_transport = "lmtp:unix:/var/run/dovecot2_lmtp.sock";

      # For the sake of possible NixOS overrides,
      # set the default local_recipient_maps explicitly
      # The $alias_maps trick means that aliases will resolve correctly
      # Lightly documented here: http://www.postfix.org/LOCAL_RECIPIENT_README.html#main_config
      local_recipient_maps = [ "ldap:${ldapSenderMap}" "$alias_maps" ];

      # Require that registered accounts are authenticated to send mail as them
      smtpd_sender_login_maps = [ "ldap:${ldapSenderMap}" "$alias_maps" ];

      # Written to /etc/postfix by the nix config
      alias_maps = [ "hash:/etc/postfix/redbrick_aliases" ];

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
        # Allow hosts with any hostname internally to connect
        "permit_mynetworks"
        "reject_invalid_helo_hostname" "reject_non_fqdn_helo_hostname"
        # This will reject all incoming mail without a HELO hostname that
        # properly resolves in DNS. This is a somewhat restrictive check and may
        # reject legitimate mail.
        "reject_unknown_helo_hostname"
      ]);
      smtpd_sender_restrictions = builtins.concatStringsSep ", " ([
        # Check the user isn't mailmgr
        "check_sasl_access hash:/var/lib/postfix/conf/sender_whitelist"
        # Not even good users should break these rules
        "reject_non_fqdn_sender" "reject_unknown_sender_domain"
        # Allow authenticated users to send their email as themselves
        "reject_sender_login_mismatch" "permit_sasl_authenticated"
        # Prevent anyone from @${tld} sending mail unauthenticated
        "check_sender_access hash:/var/lib/postfix/conf/sender_blacklist"
        "reject_unlisted_sender" "reject_unauth_pipelining"
        "warn_if_reject" "reject_unverified_sender"
      ]);
      smtpd_recipient_restrictions = builtins.concatStringsSep ", " (commonRestrictions ++ [
        "reject_non_fqdn_recipient" "reject_unknown_recipient_domain"
        "reject_unverified_recipient"
      ]);
      smtpd_data_restrictions = builtins.concatStringsSep ", " (commonRestrictions ++ [
        "reject_multi_recipient_bounce"
      ]);
      smtpd_relay_restrictions = builtins.concatStringsSep ", " [
        # Check the user isn't mailmgr
        "check_sasl_access hash:/var/lib/postfix/conf/sender_whitelist"
        "reject_unlisted_sender"
        "reject_sender_login_mismatch" "permit_sasl_authenticated"
        # TODO Consider explicit reject here
        # !!! THIS SETTING PREVENTS YOU FROM BEING AN OPEN RELAY !!!
        "reject_unauth_destination"
        # !!!      DO NOT REMOVE IT UNDER ANY CIRCUMSTANCES      !!!
      ];
      smtpd_client_restrictions = builtins.concatStringsSep ", " (commonRestrictions ++ [
        # Allow hosts with any hostname internally to connect
        "permit_mynetworks"
        # Reject failed reverse records
        "reject_unknown_reverse_client_hostname"
        # Reject unauthenticated connections from local addresses. This is due to
        # a limitation in rspamd which prevents us checking for spoofing internally
        # see rspamd.nix
        "check_client_a_access cidr:/var/lib/postfix/conf/unauth_ip_blacklist"
        # This will reject all incoming connections without a reverse DNS
        # entry that resolves back to the client's IP address. This is a very
        # restrictive check and may reject legitimate mail.
        "warn_if_reject" "reject_unknown_client_hostname"
      ]);
    };
  };
}
