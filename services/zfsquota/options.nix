{ lib, ... }:
{
  options.redbrick.zfsquotaDataset = lib.mkOption {
    description = "Name of the ZFS dataset to apply quotas to";
    default = null;
    type = lib.types.str;
  };
}
