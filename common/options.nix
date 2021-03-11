{ lib, ... }:
with lib;
{
  options.redbrick = {
    tld = mkOption {
      description = "Source of truth of TLD for entire Nix config";
      default = "redbrick.dcu.ie";
      type = types.nullOr types.str;
    };

    skipCustomVhosts = mkOption {
      description = "Skip all vhosts that are not based on the TLD. Useful for development boxes";
      default = false;
      defaultText = "False (compile the vhosts)";
      type = types.nullOr types.bool;
    };

    ldapServers = mkOption {
      description = "Configuration of LDAP servers to cluster together";
      default = [];
      type = types.listOf (types.submodule {
        options = {
          ipAddress = mkOption {
            description = "IP address of the LDAP host";
            type = types.str;
          };
          replicationId = mkOption {
            description = "MAX 3 digit number to use as the host's replication ID";
            type = types.int;
          };
        };
      });
    };

    smtpBindAddress = mkOption {
      description = "Address that Postfix expects to send and receive mail on";
      default = "192.168.0.158";
      type = types.str;
    };

    smtpExternalAddress = mkOption {
      description = "The appropriate public IP forwarding port 587/993 for this mail host";
      default = "136.206.15.3";
      type = types.str;
    };

    ircServerAddress = mkOption {
      description = "The appropriate public IP forwarding port 6697 for this IRC host";
      default = "136.206.15.3";
      type = types.str;
    };

    znapzendSourceDataset = mkOption {
      description = "Dataset on the local system to send to Albus";
      example = "znfs";
      type = types.str;
    };

    znapzendDestDataset = mkOption {
      description = "Dataset on Albus to write the backup to (full path)";
      example = "zbackup/nfs";
      type = types.str;
    };
  };
}
