{ lib, ... }:
{
  options.redbrick = {
    tld = lib.mkOption {
      description = "Source of truth of TLD for entire Nix config";
      default = "redbrick.dcu.ie";
      type = lib.types.nullOr lib.types.str;
    };

    skipCustomVhosts = lib.mkOption {
      description = "Skip all vhosts that are not based on the TLD. Useful for development boxes";
      default = false;
      defaultText = "False (compile the vhosts)";
      type = lib.types.nullOr lib.types.bool;
    };

    ldapSlaveTo = lib.mkOption {
      description = "If this host is going to be an LDAP slave, set this to a hostname";
      default = null;
      defaultText = "Null (this is a master)";
      type = lib.types.nullOr lib.types.str;
    };

    smtpBindAddress = lib.mkOption {
      description = "Address that Postfix expects to send and receive mail on";
      default = "192.168.0.158";
      type = lib.types.str;
    };

    smtpExternalAddress = lib.mkOption {
      description = "The appropriate public IP forwarding port 587/993 for this mail host";
      default = "136.206.15.3";
      type = lib.types.str;
    };
  };
}
