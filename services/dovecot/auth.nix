{common, pkgs, tld, ...}:
let
  bindCreds = import /var/secrets/dovecot_auth.nix;

  ldapConfig = pkgs.writeText "dovecot-ldap-config" ''
    !include /var/secrets/dovecot_auth.conf
    hosts = ${common.ldapHost}
    ldap_version = 3
    auth_bind = no
    base = ou=accounts,o=redbrick
    deref = never
    scope = subtree
    user_attrs = uid=uid,homeDirectory=home
    user_filter = (&(objectclass=posixAccount)(uid=%n))
    pass_attrs = uid=uid,homeDirectory=home,userPassword=password
    pass_filter = (&(objectclass=posixAccount)(uid=%n))
    iterate_attrs = =user=%{ldap:uid}
    iterate_filter = (objectClass=posixAccount)
    default_pass_scheme = CRYPT
  '';

in pkgs.writeText "dovecot-auth-config" ''
  # cache all authentication results for one hour
  auth_cache_size = 10M
  auth_cache_ttl = 1 hour
  auth_cache_negative_ttl = 1 hour

  # Set domain for login names without a domain specified
  auth_default_realm = ${tld}

  # only use plain username/password auth - OK since everything is over TLS
  auth_mechanisms = plain

  # Don't strip domain from username. Means that mail_location can reference %d
  auth_username_format = %Lu

  # passdb specifies how users are authenticated - LDAP in my case
  passdb {
    driver = ldap
    args = ${ldapConfig}
  }

  userdb {
    driver = ldap
    args = ${ldapConfig}
  }
''
