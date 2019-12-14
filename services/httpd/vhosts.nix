{ config, ... }:
with (import ./shared.nix);
let
  users = import ./users.nix;

  # This is appended at the bottom
  # to ensure that custom vhosts take preference
  userVhosts = builtins.map (user: vhost {
    hostName = "${user.uid}.${tld}";
    documentRoot = common.userWebtree user.uid;
    user = user.uid;
    group = user.gid;
    serverAliases = [];
  }) users;
in [
  (vhost {
    hostName = "abovethefold.es";
    documentRoot = "${webtree}/r/receive/abovethefold";
    user = "receive";
    group = "staff";
  })
  (vhost {
    hostName = "blog.${tld}";
    documentRoot = "${webtree}/vhosts/blog.redbrick.dcu.ie";
    user = "wwwrun";
    group = "wwwrun";
    serverAliases = [];
  })
  (vhost {
    hostName = "alanwalsh.${tld}";
    documentRoot = "${webtree}/s/sonic/cv";
    user = "sonic";
    group = "member";
    serverAliases = [];
  })
  (vhost {
    hostName = "assassins.${tld}";
    documentRoot = "${webtree}/a/art_wolf/assassins";
    user = "art_wolf";
    group = "associat";
    serverAliases = [];
  })
  (vhost {
    hostName = "astro.${tld}";
    documentRoot = "${webtree}/k/k100/astro";
    user = "k100";
    group = "associat";
    serverAliases = [];
  })
  (vhost {
    hostName = "birthday.${tld}";
    documentRoot = "${webtree}/s/space/Redbrick-Turns-20/resources/public";
    user = "space";
    group = "member";
    serverAliases = [];
  })
  (vhost {
    hostName = "blog.lessthanthree.be";
    documentRoot = "${webtree}/o/ornat/blog";
    user = "ornat";
    group = "member";
  })
  (vhost {
    hostName = "bricket.${tld}";
    documentRoot = "${webtree}/w/werdz/bricket";
    user = "werdz";
    group = "member";
    serverAliases = [];
  })
  (vhost {
    hostName = "brickjet.${tld}";
    documentRoot = "${webtree}/j/johan/brickjet";
    user = "johan";
    group = "member";
    serverAliases = [];
  })
  (vhost {
    hostName = "bugzilla.${tld}";
    documentRoot = "${webtree}/vhosts/bugzilla.redbrick.dcu.ie";
    user = "bugs";
    group = "redbrick";
    serverAliases = [];
  })
  (vhost {
    hostName = "butterflyexplosion.com";
    documentRoot = "${webtree}/c/carr";
    user = "carr";
    group = "associat";
  })
  (vhost {
    hostName = "ca2wiki.${tld}";
    documentRoot = "${webtree}/s/sonic/wiki";
    user = "sonic";
    group = "member";
    serverAliases = [];
  })
  (vhost {
    hostName = "ca3wiki.${tld}";
    documentRoot = "${webtree}/s/sonic/wikica3";
    user = "sonic";
    group = "member";
    serverAliases = [];
  })
  (vhost {
    hostName = "ca4wiki.${tld}";
    documentRoot = "${webtree}/s/sonic/ca4wiki";
    user = "sonic";
    group = "member";
    serverAliases = [];
  })
  (vhost {
    hostName = "ciankehoe.ie";
    documentRoot = "${webtree}/c/cianky/ciankehoe.ie/public";
    user = "cianky";
    group = "member";
  })
  (vhost {
    hostName = "colors.${tld}";
    documentRoot = "${webtree}/vhosts/colors.redbrick.dcu.ie";
    user = "wwwrun";
    group = "wwwrun";
    serverAliases = [];
  })
  (vhost {
    hostName = "committee.${tld}";
    documentRoot = "${webtree}/c/chair/blog";
    user = "chair";
    group = "committe";
    serverAliases = [];
  })
  (vhost {
    hostName = "dcudrama.ie";
    documentRoot = "${webtree}/d/drama";
    user = "drama";
    group = "society";
  })
  (vhost {
    hostName = "dibs.${tld}";
    documentRoot = "${webtree}/d/dever/dibs";
    user = "dever";
    group = "member";
    serverAliases = [];
  })
  (vhost {
    hostName = "djbdns.now.ie";
    documentRoot = "${webtree}/l/lecter/djbdns";
    user = "lecter";
    group = "associat";
  })
  (vhost {
    hostName = "forbidden.${tld}";
    documentRoot = "${webtree}/vhosts/forbidden.redbrick.dcu.ie";
    user = "stolnart";
    group = "associat";
    serverAliases = [];
  })
  (vhost {
    hostName = "forgottofollow.${tld}";
    documentRoot = "${webtree}/m/mick";
    user = "mick";
    group = "associat";
    serverAliases = [];
  })
  (vhost {
    hostName = "freedom.${tld}";
    documentRoot = "${webtree}/b/bunbun";
    user = "bunbun";
    group = "member";
    serverAliases = [];
  })
  (vhost {
    hostName = "grahambartley.com";
    documentRoot = "${webtree}/d/dedoctor";
    user = "dedoctor";
    group = "member";
  })
  (vhost {
    hostName = "h8.work";
    documentRoot = "${webtree}/a/ainran/domains/h8.work";
    user = "ainran";
    group = "member";
  })
  (vhost {
    hostName = "hack.${tld}";
    documentRoot = "${webtree}/n/newbrick";
    user = "newbrick";
    group = "redbrick";
    serverAliases = [];
  })
  (vhost {
    hostName = "hackaton.${tld}";
    documentRoot = "${webtree}/n/newbrick";
    user = "newbrick";
    group = "redbrick";
    serverAliases = [];
  })
  (vhost {
    hostName = "halenger.com";
    documentRoot = "${home}/associat/h/halenger/domains/halenger.com";
    user = "halenger";
    group = "associat";
  })
  (vhost {
    hostName = "interlan.dcu.ie";
    documentRoot = "${webtree}/vhosts/www.interlan.dcu.ie";
    user = "gamessoc";
    group = "society";
  })
  (vhost {
    hostName = "lessthanthree.be";
    documentRoot = "${webtree}/o/ornat";
    user = "ornat";
    group = "member";
  })
  (vhost {
    hostName = "mak.${tld}";
    documentRoot = "${webtree}/m/mak/mak";
    user = "mak";
    group = "associat";
    serverAliases = [];
  })
  (vhost {
    hostName = "mcmahon.${tld}";
    documentRoot = "${webtree}/m/mcmahon/wordpress";
    user = "mcmahon";
    group = "member";
    serverAliases = [];
  })
  (vhost {
    hostName = "mlane.org";
    documentRoot = "${webtree}/a/ainran/mlane";
    user = "ainran";
    group = "associat";
  })
  (vhost {
    hostName = "nemo.${tld}";
    documentRoot = "${webtree}/n/nemo/wordpress";
    user = "nemo";
    group = "associat";
    serverAliases = [];
  })
  (vhost {
    hostName = "obrienronan.com";
    documentRoot = "${webtree}/vhosts/www.obrienronan.com";
    user = "mellow";
    group = "associat";
    serverAliases = ["www.obrienronan.com" "citrix-itm.obrienronan.com"];
  })
  (vhost {
    hostName = "packages.${tld}";
    documentRoot = "${webtree}/r/rbpkg/apt";
    user = "rbpkg";
    group = "redbrick";
    serverAliases = [];
  })
  (vhost {
    hostName = "paintball.${tld}";
    documentRoot = "${webtree}/p/paintbal";
    user = "paintbal";
    group = "club";
    serverAliases = [];
  })
  (vhost {
    hostName = "performingarts.${tld}";
    documentRoot = "${webtree}/p/perfarts";
    user = "perfarts";
    group = "projects";
    serverAliases = [];
  })
  (vhost {
    hostName = "pleasetalk.${tld}";
    documentRoot = "${webtree}/p/plstalk";
    user = "plstalk";
    group = "dcu";
    serverAliases = [];
  })
  (vhost {
    hostName = "profiles.${tld}";
    documentRoot = "${webtree}/d/d_fens/profiles";
    user = "d_fens";
    group = "associat";
    serverAliases = [];
  })
  (vhost {
    hostName = "richardwalsh.ie";
    documentRoot = "${webtree}/k/koffee/";
    user = "koffee";
    group = "associat";
  })
  (vhost {
    hostName = "romana.now.ie";
    documentRoot = "${home}/associat/l/lecter/public_html";
    user = "lecter";
    group = "associat";
    serverAliases = [
      "big.wavingscreamingqueen.com"
      "dude.coolandgroovy.org"
      "eurovision.bing-bang-a-bang.com"
      "honk.for.faggots-on-strike.com"
      "romana.ipv4.now.ie"
      "romana.ipv6.now.ie"
    ];
  })
  (vhost {
    hostName = "room.${tld}";
    documentRoot = "${webtree}/e/edu/n109a";
    user = "edu";
    group = "redbrick";
    serverAliases = ["n109a.${tld}"];
  })
  (vhost {
    hostName = "ryanmcdyer.com";
    documentRoot = "${webtree}/r/ryanmcd";
    user = "ryanmcd";
    group = "member";
  })
  (vhost {
    hostName = "sadsoc.${tld}";
    documentRoot = "${webtree}/a/art_wolf/sadsoc";
    user = "art_wolf";
    group = "associat";
    serverAliases = [];
  })
  (vhost {
    hostName = "security.${tld}";
    documentRoot = "${webtree}/d/d_fens/security";
    user = "d_fens";
    group = "associat";
    serverAliases = [];
  })
  (vhost {
    hostName = "shaunneary.com";
    documentRoot = "${webtree}/s/shaun/koken";
    user = "shaun";
    group = "member";
  })
  (vhost {
    hostName = "signup.${tld}";
    documentRoot = "${webtree}/e/events/csday";
    user = "events";
    group = "redbrick";
    serverAliases = [];
  })
  (vhost {
    hostName = "solarsystemscanlan.com";
    documentRoot = "${webtree}/s/singer/solarsystemscanlan.com/";
    user = "singer";
    group = "associat";
  })
  (vhost {
    hostName = "songsfromtheparlour.com";
    documentRoot = "${webtree}/vhosts/www.songsfromtheparlour.com";
    user = "parlour";
    group = "guest";
  })
  (vhost {
    hostName = "speakeasyireland.ie";
    documentRoot = "${webtree}/s/spkeasy";
    user = "spkeasy";
    group = "society";
  })
  (vhost {
    hostName = "surfnsail.${tld}";
    documentRoot = "${webtree}/s/sailing";
    user = "sailing";
    group = "club";
    serverAliases = [];
  })
  (vhost {
    hostName = "techweek.dcu.ie";
    documentRoot = "${webtree}/t/techwk/dist";
    user = "techwk";
    group = "redbrick";
  })
  (vhost {
    hostName = "thecollegeview.com";
    documentRoot = "${webtree}/p/pubsoc";
    user = "pubsoc";
    group = "society";
  })
  (vhost {
    hostName = "theinternets.be";
    documentRoot = "${webtree}/r/receive/internets";
    user = "receive";
    group = "staff";
  })
  (vhost {
    hostName = "blog.theinternets.be";
    documentRoot = "${webtree}/r/receive/blog";
    user = "receive";
    group = "staff";
    serverAliases = [];
  })
  (vhost {
    hostName = "receive.theinternets.be";
    documentRoot = "${webtree}/r/receive";
    user = "receive";
    group = "staff";
    serverAliases = [];
  })
  (vhost {
    hostName = "someoneiswrong.theinternets.be";
    documentRoot = "${webtree}/r/receive/wrong";
    user = "receive";
    group = "staff";
    serverAliases = [];
  })
  (vhost {
    hostName = "thelookdcu.com";
    documentRoot = "${webtree}/t/thelook/";
    user = "thelook";
    group = "society";
  })
  (vhost {
    hostName = "theparachichi.com";
    documentRoot = "${webtree}/v/vmuia";
    user = "vmuia";
    group = "associat";
  })
  (vhost {
    hostName = "travel.colmreilly.com";
    documentRoot = "${webtree}/n/nettles/travel/";
    user = "nettles";
    group = "associat";
    serverAliases = [];
  })
  (vhost {
    hostName = "wanderers.${tld}";
    documentRoot = "${webtree}/w/wander/";
    user = "wander";
    group = "projects";
    serverAliases = [];
  })
  (vhost {
    hostName = "wiki.colmreilly.com";
    documentRoot = "${webtree}/n/nettles/wiki/";
    user = "nettles";
    group = "associat";
    serverAliases = [];
  })
  (vhost {
    hostName = "ejmitchell.com";
    documentRoot = "${home}/member/d/deadlock/ejmitchellcom";
    user = "deadlock";
    group = "member";
  })
  (vhost {
    hostName = "iahpc.ie";
    documentRoot = "${home}/guest/iahpc/public_html";
    user = "iahpc";
    group = "guest";
  })
  (vhost {
    hostName = "luxgaa.lu";
    documentRoot = "${webtree}/s/shivo/LuxGAA";
    user = "shivo";
    group = "associat";
  })
  (vhost {
    hostName = "unkle77.com";
    documentRoot = "${webtree}/s/shivo/unkle77/wordpress/";
    user = "shivo";
    group = "associat";
  })
  (vhost {
    hostName = "x-files.${tld}";
    documentRoot = "${webtree}/f/fox_chic";
    user = "fox_chic";
    group = "associat";
    serverAliases = [];
  })
  (vhost {
    hostName = "yfg.${tld}";
    documentRoot = "${webtree}/f/finegael";
    user = "finegael";
    group = "associat";
    serverAliases = [];
  })
  (vhost {
    hostName = "youth2000.${tld}";
    documentRoot = "${webtree}/y/youth2k";
    user = "gamessoc";
    group = "society";
    serverAliases = [];
  })
  (vhost {
    hostName = "webmail.${tld}";
    documentRoot = "${webtree}/vhosts/rainloop";
    user = "wwwrun";
    group = "wwwrun";
  })
  (vhostProxy "dcufm.${tld}" "http://136.206.16.136")
  (vhostProxy "jakarta.${tld}" "http://136.206.15.59:8080")
  (vhostProxy "macspayn.${tld}" "http://136.206.15.25:3007")
  (vhostProxy "portaldev.${tld}" "http://136.206.15.61:9080")
  (vhostProxy "radio.${tld}" "http://radio.redbrick.dcu.ie:8000")
  (vhostProxy "riainccc.${tld}" "http://http://136.206.15.25:3000")
  (vhostProxy "tomcat.dregin.${tld}" "http://136.206.15.14:20002")
  (vhostProxy "webchat.${tld}" "http://127.0.0.1:16667")
  (vhostProxy "werdztomcat.${tld}" "http://136.206.15.14:20001")
  (vhostRedirect "admin.${tld}" "https://blog.redbrick.dcu.ie")
  (vhostRedirect "admins.${tld}" "https://blog.redbrick.dcu.ie")
  (vhostRedirect "ajaxterm.${tld}" "https://term.redbrick.dcu.ie")
  (vhostRedirect "anyterm.${tld}" "https://term.redbrick.dcu.ie")
  (vhostRedirect "dconcannon.${tld}" "https://www.redbrick.dcu.ie/~shimoda")
  (vhostRedirect "dermot.${tld}" "https://www.redbrick.dcu.ie/~homer")
  (vhostRedirect "devnull.${tld}" "https://www.redbrick.dcu.ie/~colmmacc")
  (vhostRedirect "devrandom.${tld}" "https://www.redbrick.dcu.ie/~marvin")
  (vhostRedirect "events.${tld}" "https://redbrick.dcu.ie/events")
  (vhostRedirect "fosdem.${tld}" "https://redbrickdcu.typeform.com/to/ZwETj0")
  (vhostRedirect "github.${tld}" "https://github.com/redbrick")
  (vhostRedirect "help.${tld}" "https://wiki.redbrick.dcu.ie/mw/Helpdesk")
  (vhostRedirect "helpdesk.${tld}" "https://wiki.redbrick.dcu.ie/mw/Helpdesk")
  (vhostRedirect "helpdeskexam.${tld}" "https://md.redbrick.dcu.ie/s/SJzip7F9X#")
  (vhostRedirect "hoodies.${tld}" "https://redbrickdcu.typeform.com/to/Q4uIzR")
  (vhostRedirect "parlour.${tld}" "http://www.songsfromtheparlour.com")
  (vhostRedirect "radio.theinternets.be" "http://radio.redbrick.dcu.ie")
  (vhostRedirect "techweek.${tld}" "https://techweek.dcu.ie")
  (vhostRedirect "tickets.${tld}" "https://dcusu.ticketsolve.com/shows/873599383/events/128190598")
  (vhostRedirect "ubuntu.${tld}" "https://wiki.redbrick.dcu.ie/mw/RedBrick_Ubuntu")
] ++ userVhosts
