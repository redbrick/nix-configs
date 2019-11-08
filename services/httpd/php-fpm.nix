let
  common = import ../../common/variables.nix;
  users = import ./users.nix;
in {
  services.phpfpm.pools = with builtins; listToAttrs (map (user: {
    name = user.uid;
    value = {
      user = user.uid;
      group = user.gid;
      settings = {
        "pm" = "ondemand";
        "pm.process_idle_timeout" = "1m";
        "chdir" = user.home;
      };
    };
  }) users);
}
