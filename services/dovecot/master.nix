{common, pkgs, ...}:
pkgs.writeText "dovecot-master-config" ''
# to improve performance, disable fsync globally - we will enable it for
# some specific services later on
mail_fsync = never

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
  service_count = 256
  # set to the number of CPU cores on your server
  process_min_avail = 3
}

# Listen on LMTP port for postfix to deliver mail
service lmtp {
  inet_listener {
    port = ${builtins.toString common.dovecotLmtpPort}
  }
}

# Listen on auth socket for postfix to authenticate users
service auth {
  inet_listener {
    port = ${builtins.toString common.dovecotSaslPort}
  }
}
''
