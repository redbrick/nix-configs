# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "m1cr0man"; # Define your hostname.
  networking.domain = "redbrick.dcu.ie";
  networking.interfaces.enp1s0.ipv4.addresses = [{
    address = "192.168.0.135";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.0.254";
  networking.nameservers = ["192.168.0.4"];

  # Configure network proxy if necessary
  networking.proxy.default = "http://proxy.internal:3128/";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "uk";
    defaultLocale = "en_IE.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Dublin";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim git jre screen unzip
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys =
    ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnVLSh0OStxZTkXE6oGgwfFvsbvN6bFPlVfDYOwtnzn lucas@oatfield"
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPR+OTAIYr02f/WKQSXo7zYy9tkuAHYpy0ajqY6aJ7Nk m1cr0man@redbrick.dcu.ie"
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMqatoGLGjnuRUhMV5gXcNDhNs3pm/escyEXn8s9Nft4 lucas@sentinel-prime"
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJKV6EiRMZHmXI4t9H5awE3fSTU7apHsTLF2iHZQFSgy lucas@dryarch"
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOCOutDnpAaDvY70HU/PBVsHwFENuNTgMjE06N8lNDqe root@nixos"
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYKnYP4Mmyk4wQE7J6Tyr27XToKtxAhXBZr5HkEXiFq root@gelandewagen"
    ];

  # Certs
  security.acme.certs."redbricktest.ml" = {
    email = "lucas+rbtest@m1cr0man.com";
    extraDomains."mail.redbricktest.ml" = null;
    webroot = "/var/acme/.webroot";
    postRun = "systemctl reload httpd.service";
  };
  security.acme.directory = "/var/acme";

  services.httpd = {
    enable = true;
    sslServerKey = "/var/acme/redbricktest.ml/key.pem";
    sslServerCert = "/var/acme/redbricktest.ml/fullchain.pem";

    # Only acme certs are accessible via port 80,
    # everything else is explicitly upgraded to https
    virtualHosts = [{
      hostName = "redbricktest.ml";
      serverAliases = [ "*.redbricktest.ml" ];
      servedDirs = [{
        urlPath = "/.well-known/acme-challenge";
        dir = "/var/acme/.webroot/.well-known/acme-challenge";
      }];

      extraConfig = ''
        RewriteEngine On
        RewriteCond %{HTTPS} off
        RewriteCond %{REQUEST_URI} !^/\.well-known/.*$ [NC]
        RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301]
      '';
    }];

    adminAddr = "lucas+rbtest@m1cr0man.com";
    hostName = "localhost";

    listen = [{ port = 80; }];
  };

  # Enable rsyslog
  services.rsyslogd.enable = true;
  services.rsyslogd.extraConfig = "*.* @log.internal:6514;RSYSLOG_SyslogProtocol23Format";

  services.bind.enable = true;
  services.bind.zones = [
    {
      file = "/var/dns/redbricktest.ml";
      master = true;
      name = "redbricktest.ml";
    }
    {
      file = "/var/dns/redbricktest.ml.rr";
      master = true;
      name = "15.206.136.in-addr.arpa";
    }
  ];

  # Email stuff
  services.postfix.enable = false;
  services.postfix.hostname = "newmail.redbrick.dcu.ie";
  services.postfix.destination = ["newmail.redbrick.dcu.ie" "localhost"];
  services.postfix.origin = "redbrick.dcu.ie";
  services.postfix.recipientDelimiter = "+";
  services.postfix.setSendmail = true;
  services.postfix.extraConfig = ''
# disable "new mail" notifications for local unix users
# biff = no

# directory to store mail for local unix users
mail_spool_directory = /var/mail/local

# prevent spammers from searching for valid users
disable_vrfy_command = yes

# require properly formatted email addresses - prevents a lot of spam
strict_rfc821_envelopes = yes

# don't give any helpful info when a mailbox doesn't exist
show_user_unknown_table_name = no

# limit maximum e-mail size to 50MB. mailbox size must be at least as big as
# the message size for the mail to be accepted, but has no meaning after
# that since we are using Dovecot for delivery.
message_size_limit = 51200000
mailbox_size_limit = 51200000

# require addresses of the form "user@domain.tld"
allow_percent_hack = no
swap_bangpath = no

# path to the SSL certificate for the mail server:q
smtpd_tls_cert_file = /var/acme/redbricktest.ml/fullchain.pem
smtpd_tls_key_file = /var/acme/redbricktest.ml/key.pem

# I have two certificates - one is RSA, the other uses the newer ECC. ECC is
# faster and arguably more secure, but many mail servers don't yet support
# it. I enable both types in postfix, but you most likely only have a single
# RSA cert, and don't need to include these three lines.
#smtpd_tls_eccert_file = /usr/local/etc/ssl/certs/mail.example.com.ecc.crt
#smtpd_tls_eckey_file = /usr/local/etc/ssl/certs/mail.example.com.ecc.key
#smtpd_tls_eecdh_grade = ultra

# Path to your trusted certificates file. Usually provided by a
# ca-certificates package or similar.
smtp_tls_CAfile=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt

# These two lines define how postfix will connect to other mail servers.
# DANE is a stronger form of opportunistic TLS. You can read about it here:
# http://www.postfix.org/TLS_README.html#client_tls_dane
#smtp_tls_security_level = dane
#smtp_dns_support_level = dnssec
# DANE requires a DNSSEC capable resolver. If your DNS resolver doesn't
# support DNSSEC, remove the above two lines and uncomment the below:
smtp_tls_security_level = may

# IP address used by postfix to send outgoing mail. You only need this if
# your machine has multiple IP addresses - set it to your MX address to
# satisfy your SPF record.
# TODO allow this machine to connect to public addresses to send mail
smtp_bind_address = 192.168.0.135
# http://www.postfix.org/BASIC_CONFIGURATION_README.html#proxy_interfaces
proxy_interfaces = 136.206.15.5
#smtp_bind_address6 = 2001:db8::3

# Here we define the options for "mandatory" TLS. In our setup, TLS is only
# "mandatory" for authenticating users. I got these settings from Mozilla's
# SSL reccomentations page.
#
# NOTE: do not attempt to make TLS mandatory for all incoming/outgoing
# connections. Do not attempt to change the default cipherlist for non-
# mandatory connections either. There are still a lot of mail servers out
# there that do not use TLS, and many that do only support old ciphers.
# Forcing TLS for everyone *will* cause you to lose mail.
smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1, TLSv1.2
smtpd_tls_mandatory_ciphers = high
tls_high_cipherlist = ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256

# tickets and compression have known vulnerabilities
tls_ssl_options = no_ticket, no_compression

# it's more secure to generate your own DH params
# TODO
# smtpd_tls_dh512_param_file  = /usr/local/etc/ssl/dh512.pem
# smtpd_tls_dh1024_param_file = /usr/local/etc/ssl/dh2048.pem

# cache incoming and outgoing TLS sessions
smtpd_tls_session_cache_database = /var/tmp/smtpd_tlscache
smtp_tls_session_cache_database  = /var/tmp/smtp_tlscache

# enable SMTPD auth. Dovecot will place an `auth` socket in postfix's
# runtime directory that we will use for authentication.
smtpd_sasl_auth_enable = yes
smtpd_sasl_path = private/auth
smtpd_sasl_type = dovecot

# only allow authentication over TLS
smtpd_tls_auth_only = yes

# don't allow plaintext auth methods on unencrypted connections
smtpd_sasl_security_options = noanonymous, noplaintext
# but plaintext auth is fine when using TLS
smtpd_sasl_tls_security_options = noanonymous

# add a message header when email was recieved over TLS
smtpd_tls_received_header = yes

# require that connecting mail servers identify themselves - this greatly
# reduces spam
smtpd_helo_required = yes

# The following block specifies some security restrictions for incoming
# mail. The gist of it is, authenticated users and connections from
# localhost can do anything they want. Random people connecting over the
# internet are treated with more suspicion: they must have a reverse DNS
# entry and present a valid, FQDN HELO hostname. In addition, they can only
# send mail to valid mailboxes on the server, and the sender's domain must
# actually exist.
smtpd_client_restrictions =
permit_mynetworks,
permit_sasl_authenticated,
reject_unknown_reverse_client_hostname,
# you might want to consider:
#  reject_unknown_client_hostname,
# here. This will reject all incoming connections without a reverse DNS
# entry that resolves back to the client's IP address. This is a very
# restrictive check and may reject legitimate mail.
reject_unauth_pipelining
smtpd_helo_restrictions =
permit_mynetworks,
permit_sasl_authenticated,
reject_invalid_helo_hostname,
reject_non_fqdn_helo_hostname,
# you might want to consider:
#  reject_unknown_helo_hostname,
# here. This will reject all incoming mail without a HELO hostname that
# properly resolves in DNS. This is a somewhat restrictive check and may
# reject legitimate mail.
reject_unauth_pipelining
smtpd_sender_restrictions =
permit_mynetworks,
permit_sasl_authenticated,
reject_non_fqdn_sender,
reject_unknown_sender_domain,
reject_unauth_pipelining
smtpd_relay_restrictions =
permit_mynetworks,
permit_sasl_authenticated,
# !!! THIS SETTING PREVENTS YOU FROM BEING AN OPEN RELAY !!!
reject_unauth_destination
# !!!      DO NOT REMOVE IT UNDER ANY CIRCUMSTANCES      !!!
smtpd_recipient_restrictions =
permit_mynetworks,
permit_sasl_authenticated,
reject_non_fqdn_recipient,
reject_unknown_recipient_domain,
reject_unauth_pipelining,
reject_unverified_recipient
smtpd_data_restrictions =
permit_mynetworks,
permit_sasl_authenticated,
reject_multi_recipient_bounce,
reject_unauth_pipelining

# deliver mail for virtual users to Dovecot's LMTP socket
virtual_transport = lmtp:unix:private/dovecot-lmtp

# LDAP query to find which domains we accept mail for
virtual_mailbox_domains = ldap:/usr/local/etc/postfix/ldap-virtual-mailbox-domains.cf
# LDAP query to find which email addresses we accept mail for
virtual_mailbox_maps = ldap:/usr/local/etc/postfix/ldap-virtual-mailbox-maps.cf, hash:/usr/local/etc/postfix/system-virtual-mailboxes
# LDAP query to find a user's email aliases
virtual_alias_maps = ldap:/usr/local/etc/postfix/ldap-virtual-alias-maps.cf

# We'll uncomment these when we set up rspamd later:
# milter_protocol = 6
# milter_default_action = accept
# smtpd_milters = unix:/var/run/rspamd/milter.sock
# milter_mail_macros = i {mail_addr} {client_addr} {client_name} {auth_authen}
'';

  #nixpkgs.config.allowUnfree = true;
  #services.minecraft-server.enable = true;
  #services.minecraft-server.eula = true;
  #services.minecraft-server.dataDir = "/var/lib/minecraft/craigmeup";
  #services.minecraft-server.declarative = false;
  #services.minecraft-server.package = pkgs.minecraft-server_1_14_2;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 53 80 443 25 587 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}
