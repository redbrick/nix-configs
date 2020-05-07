{ config, ... }:
with (import ./shared.nix { tld = config.redbrick.tld; });
let
  users = import ./users.nix;

  # Reserved or ignored names, e.g. for service accounts
  # where the service has its own vhost
  userBlacklist = [
    "paste"
    "wiki"
    "cmtwiki"
    "lists"
  ];

  # This is appended at the top
  # to ensure that custom vhosts take preference
  userVhosts = with builtins; listToAttrs (map (user: {
    name = "${user.uid}.${tld}";
    value = vhost {
      documentRoot = common.userWebtree user.uid;
      user = user.uid;
      group = user.gid;
    };
  }) (filter (user: !elem user.uid userBlacklist) users));
in (userVhosts // {
  "bash.${tld}" = vhost {
    documentRoot = "${webtree}/y/yosarian/bash";
    user = "yosarian";
    group = "associat";
  };
  "blog.${tld}" = vhost {
    documentRoot = "${webtree}/vhosts/blog.redbrick.dcu.ie";
    user = "wwwrun";
    group = "wwwrun";
  };
  "alanwalsh.${tld}" = vhost {
    documentRoot = "${webtree}/s/sonic/cv";
    user = "sonic";
    group = "member";
  };
  "assassins.${tld}" = vhost {
    documentRoot = "${webtree}/a/art_wolf/assassins";
    user = "art_wolf";
    group = "associat";
  };
  "astro.${tld}" = vhost {
    documentRoot = "${webtree}/k/k100/astro";
    user = "k100";
    group = "associat";
  };
  "birthday.${tld}" = vhost {
    documentRoot = "${webtree}/s/space/Redbrick-Turns-20/resources/public";
    user = "space";
    group = "member";
  };
  "bricket.${tld}" = vhost {
    documentRoot = "${webtree}/w/werdz/bricket";
    user = "werdz";
    group = "member";
  };
  "bugzilla.${tld}" = vhost {
    documentRoot = "${webtree}/vhosts/bugzilla.redbrick.dcu.ie";
    user = "bugs";
    group = "redbrick";
  };
  "ca2wiki.${tld}" = vhost {
    documentRoot = "${webtree}/s/sonic/wiki";
    user = "sonic";
    group = "member";
  };
  "ca3wiki.${tld}" = vhost {
    documentRoot = "${webtree}/s/sonic/wikica3";
    user = "sonic";
    group = "member";
  };
  "ca4wiki.${tld}" = vhost {
    documentRoot = "${webtree}/s/sonic/ca4wiki";
    user = "sonic";
    group = "member";
  };
  "colors.${tld}" = vhost {
    documentRoot = "${webtree}/vhosts/colors.redbrick.dcu.ie";
    user = "wwwrun";
    group = "wwwrun";
  };
  "committee.${tld}" = vhost {
    documentRoot = "${webtree}/c/chair/blog";
    user = "chair";
    group = "committe";
  };
  "forbidden.${tld}" = vhost {
    documentRoot = "${webtree}/vhosts/forbidden.redbrick.dcu.ie";
    user = "stolnart";
    group = "associat";
  };
  "forgottofollow.${tld}" = vhost {
    documentRoot = "${webtree}/m/mick";
    user = "mick";
    group = "associat";
  };
  "freedom.${tld}" = vhost {
    documentRoot = "${webtree}/b/bunbun";
    user = "bunbun";
    group = "member";
  };
  "hack.${tld}" = vhost {
    documentRoot = "${webtree}/n/newbrick";
    user = "newbrick";
    group = "redbrick";
  };
  "hackaton.${tld}" = vhost {
    documentRoot = "${webtree}/n/newbrick";
    user = "newbrick";
    group = "redbrick";
  };
  "gamessoc.${tld}" = vhost {
    documentRoot = "${webtree}/g/games";
    user = "gamessoc";
    group = "society";
    serverAliases = [ "games.${tld}" "www.games.${tld}" ];
    extraConfig = ''
      RedirectMatch 301 "^games\.(.*)$" "https://www.games.$1"
      RedirectMatch 301 "^gamesoc\.(.*)$" "https://www.games.$1"
    '';
  };
  "mak.${tld}" = vhost {
    documentRoot = "${webtree}/m/mak/mak";
    user = "mak";
    group = "associat";
  };
  "mcmahon.${tld}" = vhost {
    documentRoot = "${webtree}/m/mcmahon/wordpress";
    user = "mcmahon";
    group = "member";
  };
  "packages.${tld}" = vhost {
    documentRoot = "${webtree}/r/rbpkg/apt";
    user = "rbpkg";
    group = "redbrick";
  };
  "paintball.${tld}" = vhost {
    documentRoot = "${webtree}/p/paintbal";
    user = "paintbal";
    group = "club";
  };
  "performingarts.${tld}" = vhost {
    documentRoot = "${webtree}/p/perfarts";
    user = "perfarts";
    group = "projects";
  };
  "pleasetalk.${tld}" = vhost {
    documentRoot = "${webtree}/p/plstalk";
    user = "plstalk";
    group = "dcu";
  };
  "profiles.${tld}" = vhost {
    documentRoot = "${webtree}/d/d_fens/profiles";
    user = "d_fens";
    group = "associat";
  };
  "room.${tld}" = vhost {
    documentRoot = "${webtree}/e/edu/n109a";
    user = "edu";
    group = "redbrick";
    serverAliases = ["n109a.${tld}"];
  };
  "sadsoc.${tld}" = vhost {
    documentRoot = "${webtree}/a/art_wolf/sadsoc";
    user = "art_wolf";
    group = "associat";
  };
  "security.${tld}" = vhost {
    documentRoot = "${webtree}/d/d_fens/security";
    user = "d_fens";
    group = "associat";
  };
  "signup.${tld}" = vhost {
    documentRoot = "${webtree}/e/events/csday";
    user = "events";
    group = "redbrick";
  };
  "surfnsail.${tld}" = vhost {
    documentRoot = "${webtree}/s/sailing";
    user = "sailing";
    group = "club";
  };
  "wanderers.${tld}" = vhost {
    documentRoot = "${webtree}/w/wander/";
    user = "wander";
    group = "projects";
  };
  "webmail.${tld}" = vhost {
    documentRoot = "${webtree}/vhosts/rainloop";
    user = "wwwrun";
    group = "wwwrun";
  };
  "x-files.${tld}" = vhost {
    documentRoot = "${webtree}/f/fox_chic";
    user = "fox_chic";
    group = "associat";
  };
  "yfg.${tld}" = vhost {
    documentRoot = "${webtree}/f/finegael";
    user = "finegael";
    group = "associat";
  };
  "youth2000.${tld}" = vhost {
    documentRoot = "${webtree}/y/youth2k";
    user = "gamessoc";
    group = "society";
  };
  "git.${tld}" = vhostProxy "http://localhost:3000/";
  "prometheus.${tld}" = vhostProxy "http://localhost:9090/";
  "graphs.${tld}" = vhostProxy "http://localhost:3001/";
  "dcufm.${tld}" = vhostProxy "http://136.206.15.74/";
  "jakarta.${tld}" = vhostProxy "http://136.206.15.59:8080/";
  "macspayn.${tld}" = vhostProxy "http://136.206.15.25:3007/";
  "portaldev.${tld}" = vhostProxy "http://136.206.15.61:9080/";
  "radio.${tld}" = vhostProxy "http://radio.${tld}:8000/";
  "riainccc.${tld}" = vhostProxy "http://http://136.206.15.25:3000/";
  "tomcat.dregin.${tld}" = vhostProxy "http://136.206.15.14:20002/";
  "webchat.${tld}" = vhostProxy "http://127.0.0.1:16667/";
  "werdztomcat.${tld}" = vhostProxy "http://136.206.15.14:20001/";
  "www.${tld}" = vhostRedirect "https://${tld}/";
  "admin.${tld}" = vhostRedirect "https://blog.${tld}/";
  "admins.${tld}" = vhostRedirect "https://blog.${tld}/";
  "ajaxterm.${tld}" = vhostRedirect "https://term.${tld}/";
  "anyterm.${tld}" = vhostRedirect "https://term.${tld}/";
  "dconcannon.${tld}" = vhostRedirect "https://shimoda.${tld}/";
  "dermot.${tld}" = vhostRedirect "https://homer.${tld}/";
  "devnull.${tld}" = vhostRedirect "https://colmmacc.${tld}/";
  "devrandom.${tld}" = vhostRedirect "https://marvin.${tld}/";
  "events.${tld}" = vhostRedirect "https://${tld}/events/";
  "fosdem.${tld}" = vhostRedirect "https://redbrickdcu.typeform.com/to/ZwETj0";
  "github.${tld}" = vhostRedirect "https://github.com/redbrick/";
  "help.${tld}" = vhostRedirect "https://wiki.${tld}/mw/Helpdesk";
  "helpdesk.${tld}" = vhostRedirect "https://wiki.${tld}/mw/Helpdesk";
  "helpdeskexam.${tld}" = vhostRedirect "https://md.${tld}/s/SJzip7F9X#";
  "mail.${tld}" = vhostRedirect "https://webmail.${tld}/";
  "hoodies.${tld}" = vhostRedirect "https://redbrickdcu.typeform.com/to/Q4uIzR";
  "parlour.${tld}" = vhostRedirect "https://songsfromtheparlour.com/";
  "sistem.${tld}" = vhostRedirect "https://sistem.intersocs.ie/";
  "techweek.${tld}" = vhostRedirect "https://techweek.dcu.ie/";
  "tickets.${tld}" = vhostRedirect "https://dcusu.ticketsolve.com/shows/873599383/events/128190598";
  "ubuntu.${tld}" = vhostRedirect "https://wiki.${tld}/mw/RedBrick_Ubuntu";

} // (if (config.redbrick.skipCustomVhosts) then {} else {

  "abovethefold.es" = vhost {
    documentRoot = "${webtree}/r/receive/abovethefold";
    user = "receive";
    group = "staff";
    wwwRedirect = true;
    serverAliases = [ "www.abovethefold.es" ];
  };
  "butterflyexplosion.com" = vhost {
    documentRoot = "${webtree}/c/carr";
    user = "carr";
    group = "associat";
    wwwRedirect = true;
    serverAliases = [ "www.butterflyexplosion.com" ];
  };
  "ciankehoe.ie" = vhost {
    documentRoot = "${webtree}/c/cianky/ciankehoe.ie/public";
    user = "cianky";
    group = "member";
  };
  "dcudrama.ie" = vhost {
    documentRoot = "${webtree}/d/drama";
    user = "drama";
    group = "society";
    wwwRedirect = true;
    serverAliases = [ "www.dcudrama.ie" ];
  };
  "djbdns.now.ie" = vhost {
    documentRoot = "${webtree}/l/lecter/djbdns";
    user = "lecter";
    group = "associat";
  };
  "grahambartley.com" = vhost {
    documentRoot = "${webtree}/d/dedoctor";
    user = "dedoctor";
    group = "member";
    wwwRedirect = true;
    serverAliases = [ "www.grahambartley.com" ];
  };
  "h8.work" = vhost {
    documentRoot = "${webtree}/a/ainran/domains/h8.work";
    user = "ainran";
    group = "member";
    wwwRedirect = true;
    serverAliases = [ "www.h8.work" ];
  };
  "halenger.com" = vhost {
    documentRoot = "${home}/associat/h/halenger/domains/halenger.com";
    user = "halenger";
    group = "associat";
    wwwRedirect = true;
    serverAliases = [ "www.halenger.com" ];
  };
  "lessthanthree.be" = vhost {
    documentRoot = "${webtree}/o/ornat";
    user = "ornat";
    group = "member";
    wwwRedirect = true;
    serverAliases = [ "www.lessthanthree.be" ];
  };
  "blog.lessthanthree.be" = vhost {
    documentRoot = "${webtree}/o/ornat/blog";
    user = "ornat";
    group = "member";
  };
  "mlane.org" = vhost {
    documentRoot = "${webtree}/a/ainran/mlane";
    user = "ainran";
    group = "associat";
    wwwRedirect = true;
    serverAliases = [ "www.mlane.org" ];
  };
  "obrienronan.com" = vhost {
    documentRoot = "${webtree}/vhosts/www.obrienronan.com";
    user = "mellow";
    group = "associat";
    wwwRedirect = true;
    serverAliases = [ "www.obrienronan.com" ];
  };
  "richardwalsh.ie" = vhost {
    documentRoot = "${webtree}/k/koffee/";
    user = "koffee";
    group = "associat";
    wwwRedirect = true;
    serverAliases = [ "www.richardwalsh.ie" ];
  };
  "romana.now.ie" = vhost {
    documentRoot = "${home}/associat/l/lecter/public_html";
    user = "lecter";
    group = "associat";
    serverAliases = [
      "big.wavingscreamingqueen.com"
      "dude.coolandgroovy.org"
      "honk.for.faggots-on-strike.com"
    ];
  };
  "ryanmcdyer.com" = vhost {
    documentRoot = "${webtree}/r/ryanmcd";
    user = "ryanmcd";
    group = "member";
    wwwRedirect = true;
    serverAliases = [ "www.ryanmcdyer.com" ];
  };
  "shaunneary.com" = vhost {
    documentRoot = "${webtree}/s/shaun/koken";
    user = "shaun";
    group = "member";
    extraConfig = ''
      RedirectMatch 301 "^/~shaun/koken(/(.*))?$" "/$1"
    '';
    # TODO shout at shaun, his www. NS points to a different server
  };
  "solarsystemscanlan.com" = vhost {
    documentRoot = "${webtree}/s/singer/solarsystemscanlan.com/";
    user = "singer";
    group = "associat";
    wwwRedirect = true;
    serverAliases = [ "www.solarsystemscanlan.com" ];
  };
  "songsfromtheparlour.com" = vhost {
    documentRoot = "${webtree}/vhosts/www.songsfromtheparlour.com";
    user = "parlour";
    group = "guest";
    wwwRedirect = true;
    serverAliases = [ "www.songsfromtheparlour.com" ];
  };
  "techweek.dcu.ie" = vhost {
    documentRoot = "${webtree}/t/techwk/dist";
    user = "techwk";
    group = "redbrick";
  };
  "thecollegeview.com" = vhost {
    documentRoot = "${webtree}/p/pubsoc";
    user = "pubsoc";
    group = "society";
    wwwRedirect = true;
    serverAliases = [ "www.thecollegeview.com" ];
  };
  "theinternets.be" = vhost {
    documentRoot = "${webtree}/r/receive/internets";
    user = "receive";
    group = "staff";
    wwwRedirect = true;
    serverAliases = [ "www.theinternets.be" ];
  };
  "blog.theinternets.be" = vhost {
    documentRoot = "${webtree}/r/receive/blog";
    user = "receive";
    group = "staff";
  };
  "receive.theinternets.be" = vhost {
    documentRoot = "${webtree}/r/receive";
    user = "receive";
    group = "staff";
  };
  "someoneiswrong.theinternets.be" = vhost {
    documentRoot = "${webtree}/r/receive/wrong";
    user = "receive";
    group = "staff";
  };
  "thelookdcu.com" = vhost {
    documentRoot = "${webtree}/t/thelook/";
    user = "thelook";
    group = "society";
    wwwRedirect = true;
    serverAliases = [ "www.thelookdcu.com" ];
  };
  "travel.colmreilly.com" = vhost {
    documentRoot = "${webtree}/n/nettles/travel/";
    user = "nettles";
    group = "associat";
  };
  "wiki.colmreilly.com" = vhost {
    documentRoot = "${webtree}/n/nettles/wiki/";
    user = "nettles";
    group = "associat";
  };
  "ejmitchell.com" = vhost {
    documentRoot = "${home}/member/d/deadlock/ejmitchellcom";
    user = "deadlock";
    group = "member";
    wwwRedirect = true;
    serverAliases = [ "www.ejmitchell.com" ];
  };
  "www.luxgaa.lu" = vhost {
    documentRoot = "${webtree}/s/shivo/LuxGAA";
    user = "shivo";
    group = "associat";
  };
  "unkle77.com" = vhost {
    documentRoot = "${webtree}/s/shivo/unkle77/wordpress/";
    user = "shivo";
    group = "associat";
  };
  "radio.theinternets.be" = vhostRedirect "https://radio.${tld}";
}))
