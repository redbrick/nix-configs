{lib, ...}:
with lib;
{
  discord_token = fileContents /var/secrets/ircd/discord.secret;
  irc_server = "irc.redbrick.dcu.ie:6697";
  guild_id = "568403963595063307";
  channel_mappings = {
    "#beverages"="716026722738241536";
    "#bots"="601104484692656168";
    "#bridge-testing"="775364868327866369";
    #"#corona-time"="692071508662550579";
    "#committee-contact"="568810777407127562";
    "#events"="769154545544462336"; # external-events
    #"#first-year-hub"="760849311948210196";
    "#foodie"="694653366583951403"; # food
    "#gamessoc"="613450224144482314"; # video-games
    #"#hackerclub"="568809835844337704";
    #"#hardware"="769991247112175626";
    "#helpdesk"="568810176640188460";
    "#infosec"="629062533374017543"; # security
    "#lobby"="627542044390457350";
    #"#memes"="614434947867869215";
    "#music"="600748501135130625";
    #"#pet-pics"="641720379081228338";
    "#rbAdmin"="578713901043286026";
    "#rbAnnouncements"="568809962323836940"; # announcements
    "#rbEvents"="601797137000300563"; # events
    "#sports"="753969788920922193";
  };
  suffix = "_d2";
  separator = "_";
  irc_listener_name = "discord_bridge";
  # webirc_pass = fileContents /var/secrets/ircd/discord_webirc.secret;
  webhook_prefix = "(auto-test)";
  max_nick_length = 12; # The default is 30
}
