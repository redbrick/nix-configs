{ config, ... }:
{
  services.znapzend = {
    enable = true;
    pure = true;
    autoCreation = true;
    features = {
      compressed = true;
      recvu = true;
    };
    zetup."${config.redbrick.znapzendSourceDataset}" = {
      plan = "1d=>1h,1m=>1d,6m=>1m";
      recursive = true;
      destinations.albus = {
        host = "rbbackup@albus.internal";
        dataset = config.redbrick.znapzendDestDataset;
      };
    };
  };
}
