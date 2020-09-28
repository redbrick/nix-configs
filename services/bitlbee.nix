{ config, pkgs, ... }:
let
  tld = config.redbrick.tld;
  configDir = "/var/lib/bitlbee";
  motd = pkgs.writeText "motd.txt" ''
     ____          _ ____       _      _
    |  _ \ ___  __| | __ ) _ __(_) ___| | __
    | |_) / _ \/ _` |  _ \| '__| |/ __| |/ /
    |  _ <  __/ (_| | |_) | |  | | (__|   <
    |_| \_\___|\__,_|____/|_|  |_|\___|_|\_\

          ____  _ _   _ _
         | __ )(_) |_| | |__   ___  ___
         |  _ \| | __| | '_ \ / _ \/ _ \
         | |_) | | |_| | |_) |  __/  __/
         |____/|_|\__|_|_.__/ \___|\___|

       bitlbee.redbrick.dcu.ie irc gateway

    for help see http://bitlbee.redbrick.dcu.ie
    '';
in {
  services.bitlbee = {
    inherit configDir;
    enable = true;
    plugins = [
      pkgs.bitlbee-facebook
      pkgs.bitlbee-discord
    ];
    portNumber = 6667;
    interface = "0.0.0.0";
    hostName = "bitlbee.${tld}";
    extraSettings = ''
      MotdFile = ${motd}
    '';
  };

  networking.firewall.allowedTCPPorts = [ 6667 ];
}
