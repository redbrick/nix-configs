{pkgs, ...}:
pkgs.writeText "dovecot-master-config" ''
service imap-login {
  # plain-text IMAP should only be accessible from localhost
  inet_listener imap {
    address = 127.0.0.1, ::1
  }

  # enable high-performance mode, described here:
  # https://wiki.dovecot.org/LoginProcess
  service_count = 0
  process_min_avail = 3
  vsz_limit = 1G
}

# disable POP3 altogether
service pop3-login {
  inet_listener pop3 {
    port = 0
  }
  inet_listener pop3s {
    port = 0
  }
}

# enable semi-long-lived IMAP processes to improve performance
service imap {
  # Service count must be 1 to prevent imap uid leaking and setuid issues
  # Seen as "imap(foo)<5288><JWXxCE2ks4ZZE0NM>: Fatal: setuid(foo from userdb lookup) failed with euid=bar: Operation not permitted"
  # See https://doc.dovecot.org/configuration_manual/service_configuration/
  # Docs specify you should just do this if you have multiple UIDs
  service_count = 1
  process_limit = 2000
}

# Listen on LMTP port for postfix to deliver mail
service lmtp {
  client_limit = 1
  unix_listener /var/run/dovecot2_lmtp.sock {
    user = postfix
    group = postfix
    mode = 0600
  }
}

# Listen on auth socket for postfix to authenticate users
service auth {
  client_limit = 2000
  unix_listener /var/run/dovecot2_sasl.sock {
    user = postfix
    group = postfix
    mode = 0600
  }
}
''
