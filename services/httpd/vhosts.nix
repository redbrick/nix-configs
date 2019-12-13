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
  vhost {
    hostName = "abovethefold.es";
    documentRoot = "${webtree}/r/receive/abovethefold";
    user = "recieve";
    group = "staff";
  };
  vhost {
    hostname = "blog.${tld}";
    documentRoot = "${webtree}/vhosts/blog.redbrick.dcu.ie";
    user = "wwwrun";
    group = "wwwrun";
    serverAliases = [];
  };
  vhost {
    hostname = "alanwalsh.${tld}";
    documentRoot = "${webtree}/s/sonic/cv";
    user = "sonic";
    group = "member";
    serverAliases = [];
  };
  vhost {
    hostname = "assassins.${tld}";
    documentRoot = "${webtree}/a/art_wolf/assassins";
    user = "art_wolf";
    group = "associat";
    serverAliases = [];
  };
  vhost {
    hostname = "astro.${tld}";
    documentRoot = "${webtree}/k/k100/astro";
    user = "k100";
    group = "associat";
    serverAliases = [];
  };
  vhost {
    hostname = "birthday.${tld}";
    documentRoot = "${webtree}/s/space/Redbrick-Turns-20/resources/public";
    user = "space";
    group = "member";
    serverAliases = [];
  };
  vhost {
    hostname = "blog.lessthanthree.be";
    documentRoot = "${webtree}/o/ornat/blog";
    user = "ornat";
    group = "member";
  };
  vhost {
    hostname = "bricket.${tld}";
    documentRoot = "${webtree}/w/werdz/bricket";
    user = "werdz";
    group = "member";
    serverAliases = [];
  };
  vhost {
    hostname = "brickjet.${tld}";
    docuemntRoot = "${webtree}/j/johan/brickjet";
    user = "johan";
    group = "member";
    serverAliases = [];
  };
  vhost {
    hostname = "bugzilla.${tld}";
    docuemntRoot = "${webtree}/vhosts/bugzilla.redbrick.dcu.ie";
    user = "bugs";
    group = "redbrick";
    serverAliases = [];
  };
  vhost {
    hostname = "butterflyexplosion.com";
    docuemntRoot = "${webtree}/c/carr";
    user = "carr";
    group = "associat";
  };
  vhost {
    hostname = "ca2wiki.${tld}";
    docuemntRoot = "${webtree}/s/sonic/wiki";
    user = "sonic";
    group = "member";
    serverAliases = [];
  };
  vhost {
    hostname = "ca3wiki.${tld}";
    docuemntRoot = "${webtree}/s/sonic/wikica3";
    user = "sonic";
    group = "member";
    serverAliases = [];
  };
  vhost {
    hostname = "ca4wiki.${tld}";
    docuemntRoot = "${webtree}/s/sonic/ca4wiki";
    user = "sonic";
    group = "member";
    serverAliases = [];
  };
  vhost {
    hostname = "ciankehoe.ie";
    docuemntRoot = "${webtree}/c/cianky/ciankehoe.ie/public";
    user = "cianky";
    group = "member";
  };
  vhost {
    hostname = "colors.${tld}";
    docuemntRoot = "${webtree}/vhosts/colors.redbrick.dcu.ie";
    user = "www-data";
    group = "www-data";
    serverAliases = [];
  };
  vhost {
    hostname = "committee.${tld}";
    docuemntRoot = "${webtree}/c/chair/blog";
    user = "chair";
    group = "committe";
    serverAliases = [];
  };
  vhost {
    hostname = "dcudrama.ie";
    docuemntRoot = "${webtree}/d/drama";
    user = "drama";
    group = "society";
  };
  vhost {
    hostname = "dibs.${tld}";
    docuemntRoot = "${webtree}/d/dever/dibs";
    user = "dever";
    group = "member";
    serverAliases = [];
  };
  vhost {
    hostname = "djbdns.now.ie";
    docuemntRoot = "${webtree}/l/lecter/djbdns";
    user = "lecter";
    group = "associat";
  };
  vhost {
    hostname = "forbidden.${tld}";
    docuemntRoot = "${webtree}/vhosts/forbidden.redbrick.dcu.ie";
    user = "stolnart";
    group = "associat";
    serverAliases = [];
  };
  vhost {
    hostname = "forgottofollow.${tld}";
    docuemntRoot = "${webtree}/m/mick";
    user = "mick";
    group = "associat";
    serverAliases = [];
  };
  vhost {
    hostname = "freedom.${tld}";
    docuemntRoot = "${webtree}/b/bunbun";
    user = "bunbun";
    group = "member";
    serverAliases = [];
  };
  vhost {
    hostname = "gallery.${tld}";
    docuemntRoot = "${webtree}/g/gallery";
    user = "gallery";
    group = "projects";
    serverAliases = [];
  };
  vhost {
    hostname = "grahambartley.com";
    docuemntRoot = "${webtree}/d/dedoctor";
    user = "dedoctor";
    group = "member";
  };
  vhost {
    hostname = "h8.work";
    docuemntRoot = "${webtree}/a/ainran/domains/h8.work";
    user = "ainran";
    group = "memeber";
  };
  vhost {
    hostname = "hack.${tld}";
    docuemntRoot = "${webtree}/n/newbrick";
    user = "newbrick";
    group = "redbrick";
    serverAliases = [];
  };
  vhost {
    hostname = "hackaton.${tld}";
    docuemntRoot = "${webtree}/n/newbrick";
    user = "newbrick";
    group = "redbrick";
    serverAliases = [];
  };
  vhost {
    hostname = "halenger.com";
    docuemntRoot = "${home}/associat/h/halenger/domains/halenger.com";
    user = "halenger";
    group = "associat";
  };
  vhost {
    hostname = "interlan.dcu.ie";
    docuemntRoot = "${webtree}/vhosts/www.interlan.dcu.ie";
    user = "gamessoc";
    group = "society";
  };
  vhost {
    hostname = "lessthanthree.be";
    docuemntRoot = "${webtree}/o/ornat";
    user = "ornat";
    group = "member";
  };
  vhost {
    hostname = "mak.${tld}";
    docuemntRoot = "${webtree}/m/mak/mak";
    user = "mak";
    group = "associat";
    serverAliases = [];
  };
  vhost {
    hostname = "mcmahon.${tld}";
    docuemntRoot = "${webtree}/m/mcmahon/wordpress";
    user = "mcmahon";
    group = "member";
    serverAliases = [];
  };
  vhost {
    hostname = "mlane.org";
    docuemntRoot = "${webtree}/a/ainran/mlane";
    user = "ainran";
    group = "associat";
  };
  vhost {
    hostname = "nemo.${tld}";
    docuemntRoot = "${webtree}/n/nemo/wordpress";
    user = "nemo";
    group = "associat";
    serverAliases = [];
  };
  vhost {
    hostname = "obrienronan.com";
    docuemntRoot = "${webtree}/vhosts/www.obrienronan.com";
    user = "mellow";
    group = "associat";
    serverAliases = ["www.obrienronan.com" "citrix-itm.obrienronan.com"];
  };
  vhost {
    hostname = "packages.${tld}";
    docuemntRoot = "${webtree}/r/rbpkg/apt";
    user = "rbpkg";
    group = "redbrick";
    serverAliases = [];
  };
  vhost {
    hostname = "paintball.${tld}";
    docuemntRoot = "${webtree}/p/paintbal";
    user = "paintbal";
    group = "club";
    serverAliases = [];
  };
  vhost {
    hostname = "performingarts.${tld}";
    docuemntRoot = "${webtree}/p/perfarts";
    user = "perfarts";
    group = "projects";
    serverAliases = [];
  };
  vhost {
    hostname = "pkmn.${tld}";
    docuemntRoot = "${webtree}/k/koffee/pkmn";
    user = "koffee";
    group = "associat";
    serverAliases = [];
  };
  vhost {
    hostname = "pleasetalk.${tld}";
    docuemntRoot = "${webtree}/p/plstalk";
    user = "plstalk";
    group = "dcu";
    serverAliases = [];
  };
  vhost {
    hostname = "profiles.${tld}";
    docuemntRoot = "${webtree}/d/d_fens/profiles";
    user = "d_fens";
    group = "associat";
    serverAliases = [];
  };
  vhost {
    hostname = "richardwalsh.ie";
    docuemntRoot = "${webtree}/k/koffee/";
    user = "koffee";
    group = "associat";
  };
  vhost {
    hostname = "romana.now.ie";
    docuemntRoot = "${home}/associat/l/lecter/public_html";
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
  };
  vhost {
    hostname = "room.${tld}";
    docuemntRoot = "${webtree}/e/edu/n109a";
    user = "edu";
    group = "redbrick";
    serverAliases = ["n109a.${tld}"];
  };
  vhost {
    hostname = "ryanmcdyer.com";
    docuemntRoot = "${webtree}/r/ryanmcd";
    user = "ryanmcd";
    group = "member";
  };
  vhost {
    hostname = "sadsoc.${tld}";
    docuemntRoot = "${webtree}/a/art_wolf/sadsoc";
    user = "art_wolf";
    group = "associat";
    serverAliases = [];
  };
  vhost {
    hostname = "security.${tld}";
    docuemntRoot = "${webtree}/d/d_fens/security";
    user = "d_fens";
    group = "associat";
    serverAliases = [];
  };
  vhost {
    hostname = "shaunneary.com";
    docuemntRoot = "${webtree}/s/shaun/koken";
    user = "shaun";
    group = "member";
  };
  vhost {
    hostname = "signup.${tld}";
    docuemntRoot = "${webtree}/e/events/csday";
    user = "events";
    group = "redbrick";
    serverAliases = [];
  };
  vhost {
    hostname = "solarsystemscanlan.com";
    docuemntRoot = "${webtree}/s/singer/solarsystemscanlan.com/";
    user = "singer";
    group = "associat";
  };
  vhost {
    hostname = "songsfromtheparlour.com";
    docuemntRoot = "${webtree}/vhosts/www.songsfromtheparlour.com";
    user = "parlour";
    group = "guest";
  };
  vhost {
    hostname = "speakeasyireland.ie";
    docuemntRoot = "${webtree}/s/spkeasy";
    user = "spkeasy";
    group = "society";
  };
  vhost {
    hostname = "surfnsail.${tld}";
    docuemntRoot = "${webtree}/s/sailing";
    user = "sailing";
    group = "club";
    serverAliases = [];
  };
  vhost {
    hostname = "techweek.dcu.ie";
    docuemntRoot = "${webtree}/t/techwk/dist";
    user = "techwk";
    group = "redbrick";
  };
  vhost {
    hostname = "thecollegeview.com";
    docuemntRoot = "${webtree}/p/pubsoc";
    user = "pubsoc";
    group = "society";
  };
  vhost {
    hostname = "theinternets.be";
    docuemntRoot = "${webtree}/r/receive/internets";
    user = "recieve";
    group = "staff";
  };
  vhost {
    hostname = "blog.theinternets.be";
    docuemntRoot = "${webtree}/r/receive/blog";
    user = "recieve";
    group = "staff";
  };
  vhost {
    hostname = "receive.theinternets.be";
    docuemntRoot = "${webtree}/r/receive";
    user = "recieve";
    group = "staff";
  };
  vhost {
    hostname = "someoneiswrong.theinternets.be";
    docuemntRoot = "${webtree}/r/receive/wrong";
    user = "recieve";
    group = "staff";
  };
  vhost {
    hostname = "thelookdcu.com";
    docuemntRoot = "${webtree}/t/thelook/";
    user = "thelook";
    group = "society";
  };
  vhost {
    hostname = "theparachichi.com";
    docuemntRoot = "${webtree}/v/vmuia";
    user = "vmuia";
    group = "associat";
  };
  vhost {
    hostname = "travel.colmreilly.com";
    docuemntRoot = "${webtree}/n/nettles/travel/";
    user = "nettles";
    group = "associat";
  };
  vhost {
    hostname = "wanderers.${tld}";
    docuemntRoot = "${webtree}/w/wander/";
    user = "wander";
    group = "projects";
    serverAliases = [];
  };
  vhost {
    hostname = "wiki.colmreilly.com";
    docuemntRoot = "${webtree}/n/nettles/wiki/";
    user = "nettles";
    group = "associat";
  };
  vhost {
    hostname = "ejmitchell.com";
    docuemntRoot = "${home}/member/d/deadlock/ejmitchellcom";
    user = "deadlock";
    group = "member";
  };
  vhost {
    hostname = "iahpc.ie";
    docuemntRoot = "${home}/guest/iahpc/public_html";
    user = "iahpc";
    group = "guest";
  };
  vhost {
    hostname = "luxgaa.lu";
    docuemntRoot = "${webtree}/s/shivo/LuxGAA";
    user = "shivo";
    group = "associat";
  };
  vhost {
    hostname = "unkle77.com";
    docuemntRoot = "${webtree}/s/shivo/unkle77/wordpress/";
    user = "shivo";
    group = "associat";
  };
  vhost {
    hostname = "x-files.${tld}";
    docuemntRoot = "${webtree}/f/fox_chic";
    user = "fox_chic";
    group = "associat";
    serverAliases = [];
  };
  vhost {
    hostname = "yfg.${tld}";
    docuemntRoot = "${webtree}/f/finegael";
    user = "finegael";
    group = "associat";
    serverAliases = [];
  };
  vhost {
    hostname = "youth2000.${tld}";
    docuemntRoot = "${webtree}/y/youth2k";
    user = "gamessoc";
    group = "society";
    serverAliases = [];
  };
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
