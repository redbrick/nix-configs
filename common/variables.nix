{
  tld = "redbricktest.ml";

  certsDir = "/var/lib/acme";
  webrootDir = certsDir + "/.webroot";

  dovecotHost = "192.168.0.135";
  dovecotSaslPort = 3659;
  dovecotLmtpPort = 24;

  ldapHost = "ldap.internal";
}
