{lib, ...}:
with lib;
{
  discord_token = fileContents /var/secrets/ircd/discord.secret;
  irc_server = "irc.redbrick.dcu.ie:6697";
  guild_id = "568403963595063307";
  channel_mappings = {
    "#bots"="775364868327866369";
    "#rbAnnouncements"="568809962323836940";
    "#beverages"="716026722738241536";
    "#committee-contact"="775409625260228608";
    # Temp disabled "#committee-contact"="568810777407127562";
    #"#corona-time"="692071508662550579";
    #"#doggoscats"="641720379081228338";
    #"#events"="601797137000300563";
    #"#external-events"="769154545544462336";
    #"#first-year-hub"="760849311948210196";
    "#food"="694653366583951403";
    #"#hackerclub"="568809835844337704";
    #"#hardware"="769991247112175626";
    # Temp Disabled "#helpdesk"="568810176640188460";
    "#helpdesk"="775409396519010336";
    "#infosec"="775409356551618581";
    # Temp disabled "#infosec"="629062533374017543";
    "#lobby"="775364504448008203";
    # Temp disabled "#lobby"="627542044390457350";
    #"#memes"="614434947867869215";
    #"#music"="600748501135130625";
    "#rbadmin"="775409312365019166";
    # Temp disabled "#rbadmin"="578713901043286026";
    #"#sports"="753969788920922193";
    #"#video-games"="613450224144482314";
  };
  suffix = "_d2";
  separator = "_";
  irc_listener_name = "discord_bridge";
  # webirc_pass = fileContents /var/secrets/ircd/discord_webirc.secret;
  insecure = false;
  no_tls = false;
  webhook_prefix = "(auto-test)";
}
