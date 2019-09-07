{ lib, ... }:
{
  options.redbrick.ldapSlaveTo = lib.mkOption {
    description = "If this host is going to be an LDAP slave, set this to a hostname";
    default = null;
    defaultText = "Null (this is a master)";
    type = types.nullOr types.str;
  };
}
