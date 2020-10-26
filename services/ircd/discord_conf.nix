{config, lib, ...}:
let
  tld = config.redbrick.tld;
  ipAddress = config.redbrick.ircServerAddress;
  common = import ../../common/variables.nix;
in {
  discord_token = lib.fileContents /var/secrets/ircd/discord.secret;
  irc_server = "localhost:6697";
  guild_id = "568403963595063307";
  channel_mappings = {
    "#lobby"="627542044390457350";
    "#helpdesk"="568810176640188460";
    "#rbadmin"="578713901043286026";
    "#committee-contact"="627542044390457350";
    "#announcements"="627542044390457350";
  };
  suffix = "_d2";
  separator = "_";
  irc_listener_name = "_d2";
  #webirc_pass: abcdef.ghijk.lmnop
  insecure = false; # this requires restart
  no_tls = false; # requires restart
  #debug = false;
  webhook_prefix = "(auto-test)"; # this probably requires restart
}
