{ config, lib, ... }:
with lib;
{
  options.redbrick = {
    tld = mkOption {
      description = "Source of truth of TLD for entire Nix config";
      default = "redbrick.dcu.ie";
      type = types.str;
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
      type = with types; attrsOf (listOf (submodule {
        options = {
          hostName = mkOption {
            description = "DNS name of the LDAP host";
            type = str;
          };
          ipAddress = mkOption {
            description = "IP address of the LDAP host";
            type = str;
          };
          replicationId = mkOption {
            description = "MAX 3 digit number to use as the host's replication ID";
            type = int;
          };
        };
      }));
    };

    ldapCluster = mkOption {
      description = "LDAP Cluster this host should utilise/be part of. Must be in config.redbrick.ldapServers.";
      default = "redbrick";
      type = types.str;
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

    rbbackup = with types; {
      destination = mkOption {
        description = "Where to rsync the backup data to.";
        default = "rbbackup@albus.internal:/zbackup/generic/${config.networking.hostName}/";
        type = str;
      };

      sources = mkOption {
        description = "Paths on the current system to be backed up.";
        default = [];
        type = listOf str;
      };

      commands = mkOption {
        description = (
          "Commands to run before commencing copy of backups. Files created"
          + " in the current working directory will be deleted after backups are completed."
        );
        default = "";
        type = str;
      };

      extraPackages = mkOption {
        description = "Packages to make available in the backup commands scripts.";
        default = [];
        type = listOf path;
      };
    };
  };

  config.assertions = [
    {
      assertion = hasAttr config.redbrick.ldapCluster config.redbrick.ldapServers;
      message = "The ldapCluster ${config.redbrick.ldapCluster} is not configured in config.redbrick.ldapServers";
    }
  ];
}
