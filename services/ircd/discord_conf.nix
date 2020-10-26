{config, lib, ...}:
let
  tld = config.redbrick.tld;
  ipAddress = config.redbrick.ircServerAddress;
  common = import ../../common/variables.nix;
in {
  discord_token = lib.fileContents /var/secrets/ircd/discord.secret;
  irc_server = "irc.redbrick.dcu.ie:6697";
  guild_id = "568403963595063307";
  channel_mappings = {
    "#announcements"="568809962323836940";
    "#committee-contact"="568810777407127562";
    "#helpdesk"="568810176640188460";
    "#lobby"="627542044390457350";
    "#rbadmin"="578713901043286026";
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
