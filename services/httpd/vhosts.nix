let
  common = import ../../common/variables.nix;
  webtree = common.webtreeDir;
  home = common.homesDir;

  vhost = hostName: documentRoot: {
    inherit hostName documentRoot;
    enableSSL = true;
    serverAliases = [ "www.${hostName}" ];
    extraModules = [ "suexec" ];
    extraConfig = ''
      Options ExecCGI Includes Indexes SymLinksIfOwnerMatch

      AddHandler cgi-script .cgi
      AddHandler cgi-script .py
      AddHandler cgi-script .sh
      AddHandler cgi-script .pl
      AddHandler x-httpd-php .php
      AddHandler x-httpd-php .php3
      AddHandler server-parsed .shtml
      AddHandler server-parsed .html

      AddType text/html .shtml
    '';
  };
  vhostRedirect = hostName: globalRedirect: {
    inherit hostName globalRedirect;
    enableSSL = true;
    serverAliases = [ "www.${hostName}" ];
  };
  vhostProxy = hostName: proxyAddress: {
    inherit hostName;
    enableSSL = true;
    serverAliases = [ "www.${hostName}" ];
    extraConfig = ''
      <Proxy *>
        Order deny,allow
        Allow from all
      </Proxy>

      ProxyPass / ${proxyAddress}/
      ProxyPassReverse / ${proxyAddress}/
    '';
  };
in [
  (vhost "abovethefold.es" "${webtree}/r/receive/abovethefold")
  (vhost "admins.redbrick.dcu.ie" "${webtree}/vhosts/admins.redbrick.dcu.ie")
  (vhost "alanwalsh.redbrick.dcu.ie" "${webtree}/s/sonic/cv")
  (vhost "art.redbrick.dcu.ie" "${webtree}/a/artsoc")
  (vhost "assassins.redrick.dcu.ie" "${webtree}/a/art_wolf/assassins")
  (vhost "astro.redbrick.dcu.ie" "${webtree}/k/k100/astro")
  (vhost "bash.redbrick.dcu.ie" "${webtree}/y/yosarian/bash")
  (vhost "birthday.redbrick.dcu.ie" "${webtree}/s/space/Redbrick-Turns-20/resources/public")
  (vhost "blog.lessthanthree.be" "${webtree}/o/ornat/blog")
  (vhost "boards.redbrick.dcu.ie" "${webtree}/b/boards")
  (vhost "bricket.redbrick.dcu.ie" "${webtree}/w/werdz/bricket")
  (vhost "brickjet.redbrick.dcu.ie" "${webtree}/j/johan/brickjet")
  (vhost "bugzilla.redbrick.dcu.ie" "${webtree}/vhosts/bugzilla.redbrick.dcu.ie")
  (vhost "butterflyexplosion.com" "${webtree}/c/carr")
  (vhost "ca2wiki.redbrick.dcu.ie" "${webtree}/s/sonic/wiki")
  (vhost "ca3wiki.redbrick.dcu.ie" "${webtree}/s/sonic/wikica3")
  (vhost "ca4wiki.redbrick.dcu.ie" "${webtree}/s/sonic/ca4wiki")
  (vhost "ciankehoe.ie" "${webtree}/c/cianky/ciankehoe.ie/public/")
  (vhost "cmtwiki.redbrick.dcu.ie" "${webtree}/redbrick/htdocs/cmt/wiki")
  (vhost "colors.redbrick.dcu.ie" "${webtree}/vhosts/colors.redbrick.dcu.ie")
  (vhost "committee.redbrick.dcu.ie" "${webtree}/c/chair/blog")
  (vhost "cookbook.redbrick.dcu.ie" "${webtree}/c/cookbook")
  (vhost "dcudrama.ie" "${webtree}/d/drama")
  (vhost "dcufm.redbrick.dcu.ie" "${webtree}/apache2-default/")
  (vhost "dibs.redbrick.dcu.ie" "${webtree}/d/dever/dibs")
  (vhost "djbdns.now.ie" "${home}/associat/l/lecter/public_html/djbdns")
  (vhost "forbidden.redbrick.dcu.ie" "${webtree}/vhosts/forbidden.redbrick.dcu.ie")
  (vhost "forgottofollow.redbrick.dcu.ie" "${webtree}/m/mick")
  (vhost "forums.redbrick.dcu.ie" "${webtree}/f/forums")
  (vhost "freedom.redbrick.dcu.ie" "${webtree}/b/bunbun")
  (vhost "gallery.redbrick.dcu.ie" "${webtree}/g/gallery")
  (vhost "grahambartley.com" "${webtree}/d/dedoctor/")
  (vhost "h8.work" "${webtree}/a/ainran/domains/h8.work")
  (vhost "hack.redbrick.dcu.ie" "${webtree}/n/newbrick")
  (vhost "hackaton.redbrick.dcu.ie" "${webtree}/n/newbrick")
  (vhost "halenger.com" "${home}/associat/h/halenger/domains/halenger.com")
  (vhost "hoodies.redbrick.dcu.ie" "${webtree}/e/events/hoodies")
  (vhost "interlan.redbrick.dcu.ie" "${webtree}/vhosts/www.interlan.dcu.ie")
  (vhost "lessthanthree.be" "${webtree}/o/ornat")
  (vhost "mak.redbrick.dcu.ie" "${webtree}/m/mak/mak")
  (vhost "mcmahon.redbrick.dcu.ie" "${webtree}/m/mcmahon/wordpress")
  (vhost "mlane.org" "${webtree}/a/ainran/mlane")
  (vhost "n109a.redbrick.dcu.ie" "${webtree}/e/edu/n109a")
  (vhost "nemo.redbrick.dcu.ie" "${webtree}/n/nemo/wordpress")
  (vhost "obrienronan.com" "${webtree}/vhosts/www.obrienronan.com")
  (vhost "openid.redbrick.dcu.ie" "${webtree}/o/openid")
  (vhost "packages.redbrick.dcu.ie" "${webtree}/r/rbpkg/apt")
  (vhost "paintball.redbrick.dcu.ie" "${webtree}/p/paintbal")
  (vhost "performingarts.redbrick.dcu.ie" "${webtree}/p/perfarts")
  (vhost "pkmn.redbrick.dcu.ie" "${webtree}/k/koffee/pkmn")
  (vhost "pleasetalkredbrick.dcu.ie" "${webtree}/p/plstalk")
  (vhost "profiles.redbrick.dcu.ie" "${webtree}/d/d_fens/profiles")
  (vhost "rbvm.redbrick.dcu.ie" "${webtree}/vhosts/rbvm.redbrick.dcu.ie")
  (vhost "richardwalsh.ie" "${webtree}/k/koffee/")
  (vhost "romana.now.ie" "${home}/associat/l/lecter/public_html")
  (vhost "room.redbrick.dcu.ie" "${webtree}/e/edu/n109a")
  (vhost "rtd.redbrick.dcu.ie" "${webtree}/redbrick/extras/RFCs/build/html")
  (vhost "ryanmcdyer.com" "${webtree}/r/ryanmcd")
  (vhost "sadsoc.redbrick.dcu.ie" "${webtree}/a/art_wolf/sadsoc")
  (vhost "security.redbrick.dcu.ie" "${webtree}/d/d_fens/security")
  (vhost "shaunneary.com" "${webtree}/s/shaun/koken")
  (vhost "signup.redbrick.dcu.ie" "${webtree}/e/events/csday")
  (vhost "solarsystemscanlan.com" "${webtree}/s/singer/solarsystemscanlan.com/")
  (vhost "songsfromtheparlour.com" "${webtree}/vhosts/www.songsfromtheparlour.com")
  (vhost "speakeasyireland.ie" "${webtree}/s/spkeasy")
  (vhost "surfnsail.redbrick.dcu.ie" "${webtree}/s/sailing")
  (vhost "techweek.dcu.ie" "${webtree}/t/techwk/dist")
  (vhost "thecollegeview.com" "${webtree}/p/pubsoc")
  (vhost "theinternets.be" "${webtree}/r/receive/internets")# "/var/www/r/receive/blog" "/var/www/r/receive" "/var/www/r/receive/wrong")
  (vhost "thelookdcu.com" "${webtree}/t/thelook/")
  (vhost "theparachichi.com" "${webtree}/v/vmuia")
  (vhost "travel.colmreilly.com" "${webtree}/n/nettles/travel/")
  (vhost "ukiepc.redbrick.dcu.ie" "${webtree}/redbrick/ukiepc")
  (vhost "vmweb.redbrick.dcu.ie" "${webtree}/w/werdz")
  (vhost "wanderers.redbrick.dcu.ie" "${webtree}/w/wander/")
  (vhost "wiki.colmreilly.com" "${webtree}/n/nettles/wiki/")
  (vhost "wiki.redbrick.dcu.ie" "${webtree}/w/wiki")
  (vhost "ejmitchell.com" "${home}/member/d/deadlock/ejmitchellcom")
  (vhost "iahpc.ie" "${home}/guest/iahpc/public_html")
  (vhost "luxgaa.lu" "${webtree}/s/shivo/LuxGAA")
  (vhost "unkle77.com" "${webtree}/s/shivo/unkle77/wordpress/")
  (vhost "x-files.redbrick.dcu.ie" "${webtree}/f/fox_chic")
  (vhost "yfg.redbrick.dcu.ie" "${webtree}/f/finegael")
  (vhost "youth2000.redbrick.dcu.ie" "${webtree}/y/youth2k")
  (vhostProxy "jakarta.redbrick.dcu.ie" "http://136.206.15.59:8080")
  (vhostProxy "macspayn.redbrick.dcu.ie" "http://136.206.15.25:3007")
  (vhostProxy "portaldev.redbrick.dcu.ie" "http://136.206.15.61:9080")
  (vhostProxy "radio.redbrick.dcu.ie" "http://radio.redbrick.dcu.ie:8000")
  (vhostProxy "radio.theinternets.be" "http://radio.redbrick.dcu.ie:80")
  (vhostProxy "riainccc.redbrick.dcu.ie" "http://http://136.206.15.25:3000")
  (vhostProxy "tomcat.dregin.redbrick.dcu.ie" "http://136.206.15.14:20002")
  (vhostProxy "webchat.redbrick.dcu.ie" "http://136.206.15.74:9090")
  (vhostProxy "werdztomcat.redbrick.dcu.ie" "http://136.206.15.14:20001")
  (vhostRedirect "admin.redbrick.dcu.ie" "https://admins.redbrick.dcu.ie")
  (vhostRedirect "dconcannon.redbrick.dcu.ie" "https://www.redbrick.dcu.ie/~shimoda")
  (vhostRedirect "dermot.redbrick.dcu.ie" "https://www.redbrick.dcu.ie/~homer")
  (vhostRedirect "devnull.redbrick.dcu.ie" "https://www.redbrick.dcu.ie/~colmmacc")
  (vhostRedirect "devrandom.redbrick.dcu.ie" "https://www.redbrick.dcu.ie/~marvin")
  (vhostRedirect "events.redbrick.dcu.ie" "https://redbrick.dcu.ie/events")
  (vhostRedirect "fosdem.redbrick.dcu.ie" "https://redbrickdcu.typeform.com/to/ZwETj0")
  (vhostRedirect "github.redbrick.dcu.ie" "https://github.com/redbrick")
  (vhostRedirect "help.redbrick.dcu.ie" "https://wiki.redbrick.dcu.ie/mw/Helpdesk")
  (vhostRedirect "helpdesk.redbrick.dcu.ie" "https://wiki.redbrick.dcu.ie/mw/Helpdesk")
  (vhostRedirect "helpdeskexam.redbrick.dcu.ie" "https://md.redbrick.dcu.ie/s/SJzip7F9X#")
  (vhostRedirect "hoodies.redbrick.dcu.ie" "https://redbrickdcu.typeform.com/to/Q4uIzR")
  (vhostRedirect "techweek.redbrick.dcu.ie" "https://techweek.dcu.ie")
  (vhostRedirect "tickets.redbrick.dcu.ie" "https://dcusu.ticketsolve.com/shows/873599383/events/128190598")
  (vhostRedirect "ubuntu.redbrick.dcu.ie" "https://wiki.redbrick.dcu.ie/mw/RedBrick_Ubuntu")
]
