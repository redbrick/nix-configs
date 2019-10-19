{ lib, ... }:
{
  options.redbrick.zfsquotaDataset = lib.mkOption {
    description = "Name of the ZFS dataset to apply quotas to";
    default = null;
    type = lib.types.str;
  };
  options.redbrick.zfsquotaSize = lib.mkOption {
    description = "Amount of space to give users";
    default = "100M";
    type = lib.types.str;
  };
}
