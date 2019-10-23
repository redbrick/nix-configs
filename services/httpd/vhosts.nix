let
  vhost = hostName: documentRoot: {
    inherit hostName documentRoot;
    listen = [{ port = 443; }];
    enableSSL = true;
    serverAliases = [ "www.${hostName}" ];
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
    serverAliases = [ "www.${hostName}" ];
    listen = [{ port = 443; }];
    enableSSL = true;
  };
  vhostProxy = hostName: proxyAddress: {
    inherit hostName;
    listen = [{ port = 443; }];
    enableSSL = true;
    serverAliases = [ "www.${hostName}" ];
    extraConfig = ''
      ProxyRequests off
      ProxyVia Off
      ProxyPreserveHost On

      <Proxy *>
        Order deny,allow
        Allow from all
      </Proxy>

      ProxyPass / ${proxyAddress}/
      ProxyPassReverse / ${proxyAddress}/
    '';
  };
in [
  (vhost "abovethefold.es" "/webtree/r/receive/abovethefold")
  (vhost "admins.redbrick.dcu.ie" "/storage/webtree/vhosts/admins.redbrick.dcu.ie")
  (vhost "alanwalsh.redbrick.dcu.ie" "/storage/webtree/s/sonic/cv")
  (vhost "art.redbrick.dcu.ie" "/storage/webtree/a/artsoc")
  (vhost "assassins.redrick.dcu.ie" "/storage/webtree/a/art_wolf/assassins")
  (vhost "astro.redbrick.dcu.ie" "/storage/webtree/k/k100/astro")
  (vhost "bash.redbrick.dcu.ie" "/webtree/y/yosarian/bash")
  (vhost "birthday.redbrick.dcu.ie" "/storage/webtree/s/space/Redbrick-Turns-20/resources/public")
  (vhost "blog.lessthanthree.be" "/webtree/o/ornat/blog")
  (vhost "boards.redbrick.dcu.ie" "/storage/webtree/b/boards")
  (vhost "bricket.redbrick.dcu.ie" "/storage/webtree/w/werdz/bricket")
  (vhost "brickjet.redbrick.dcu.ie" "/storage/webtree/j/johan/brickjet")
  (vhost "bugzilla.redbrick.dcu.ie" "/storage/webtree/vhosts/bugzilla.redbrick.dcu.ie")
  (vhost "butterflyexplosion.com" "/webtree/c/carr")
  (vhost "ca2wiki.redbrick.dcu.ie" "/storage/webtree/s/sonic/wiki")
  (vhost "ca3wiki.redbrick.dcu.ie" "/storage/webtree/s/sonic/wikica3")
  (vhost "ca4wiki.redbrick.dcu.ie" "/storage/webtree/s/sonic/ca4wiki")
  (vhost "ciankehoe.ie" "/webtree/c/cianky/ciankehoe.ie/public/")
  (vhost "cmtwiki.redbrick.dcu.ie" "/storage/webtree/redbrick/htdocs/cmt/wiki")
  (vhost "colors.redbrick.dcu.ie" "/storage/webtree/vhosts/colors.redbrick.dcu.ie")
  (vhost "committee.redbrick.dcu.ie" "/storage/webtree/c/chair/blog")
  (vhost "cookbook.redbrick.dcu.ie" "/storage/webtree/c/cookbook")
  (vhost "dcudrama.ie" "/webtree/d/drama")
  (vhost "dcufm.redbrick.dcu.ie" "/var/www/apache2-default/")
  (vhost "dibs.redbrick.dcu.ie" "/storage/webtree/d/dever/dibs")
  (vhost "djbdns.now.ie" "/home/associat/l/lecter/public_html/djbdns")
  (vhost "forbidden.redbrick.dcu.ie" "/storage/webtree/vhosts/forbidden.redbrick.dcu.ie")
  (vhost "forgottofollow.redbrick.dcu.ie" "/storage/webtree/m/mick")
  (vhost "forums.redbrick.dcu.ie" "/storage/webtree/f/forums")
  (vhost "freedom.redbrick.dcu.ie" "/storage/webtree/b/bunbun")
  (vhost "gallery.redbrick.dcu.ie" "/storage/webtree/g/gallery")
  (vhost "grahambartley.com" "/webtree/d/dedoctor/")
  (vhost "h8.work" "/webtree/a/ainran/domains/h8.work")
  (vhost "hack.redbrick.dcu.ie" "/storage/webtree/n/newbrick")
  (vhost "hackaton.redbrick.dcu.ie" "/storage/webtree/n/newbrick")
  (vhost "halenger.com" "/home/associat/h/halenger/domains/halenger.com")
  (vhost "hoodies.redbrick.dcu.ie" "/storage/webtree/e/events/hoodies")
  (vhost "interlan.redbrick.dcu.ie" "/storage/webtree/vhosts/www.interlan.dcu.ie")
  (vhost "lessthanthree.be" "/webtree/o/ornat")
  (vhost "mak.redbrick.dcu.ie" "/storage/webtree/m/mak/mak")
  (vhost "mcmahon.redbrick.dcu.ie" "/webtree/m/mcmahon/wordpress")
  (vhost "mlane.org" "/webtree/a/ainran/mlane")
  (vhost "n109a.redbrick.dcu.ie" "/storage/webtree/e/edu/n109a")
  (vhost "nemo.redbrick.dcu.ie" "/storage/webtree/n/nemo/wordpress")
  (vhost "obrienronan.com" "/webtree/vhosts/www.obrienronan.com")
  (vhost "openid.redbrick.dcu.ie" "/storage/webtree/o/openid")
  (vhost "packages.redbrick.dcu.ie" "/webtree/r/rbpkg/apt")
  (vhost "paintball.redbrick.dcu.ie" "/storage/webtree/p/paintbal")
  (vhost "performingarts.redbrick.dcu.ie" "/storage/webtree/p/perfarts")
  (vhost "pkmn.redbrick.dcu.ie" "/storage/webtree/k/koffee/pkmn")
  (vhost "pleasetalkredbrick.dcu.ie" "/storage/webtree/p/plstalk")
  (vhost "profiles.redbrick.dcu.ie" "/storage/webtree/d/d_fens/profiles")
  (vhost "rbvm.redbrick.dcu.ie" "/webtree/vhosts/rbvm.redbrick.dcu.ie")
  (vhost "richardwalsh.ie" "/storage/webtree/k/koffee/")
  (vhost "romana.now.ie" "/home/associat/l/lecter/public_html")
  (vhost "room.redbrick.dcu.ie" "/storage/webtree/e/edu/n109a")
  (vhost "rtd.redbrick.dcu.ie" "/webtree/redbrick/extras/RFCs/build/html")
  (vhost "ryanmcdyer.com" "/webtree/r/ryanmcd")
  (vhost "sadsoc.redbrick.dcu.ie" "/storage/webtree/a/art_wolf/sadsoc")
  (vhost "security.redbrick.dcu.ie" "/storage/webtree/d/d_fens/security")
  (vhost "shaunneary.com" "/storage/webtree/s/shaun/koken")
  (vhost "signup.redbrick.dcu.ie" "/storage/webtree/e/events/csday")
  (vhost "solarsystemscanlan.com" "/webtree/s/singer/solarsystemscanlan.com/")
  (vhost "songsfromtheparlour.com" "/webtree/vhosts/www.songsfromtheparlour.com")
  (vhost "speakeasyireland.ie" "/webtree/s/spkeasy")
  (vhost "surfnsail.redbrick.dcu.ie" "/storage/webtree/s/sailing")
  (vhost "techweek.dcu.ie" "/webtree/t/techwk/dist")
  (vhost "thecollegeview.com" "/webtree/p/pubsoc")
  (vhost "theinternets.be" "/var/www/r/receive/internets" "/var/www/r/receive/blog" "/var/www/r/receive" "/var/www/r/receive/wrong")
  (vhost "thelookdcu.com" "/storage/webtree/t/thelook/")
  (vhost "theparachichi.com" "/webtree/v/vmuia")
  (vhost "travel.colmreilly.com" "/webtree/n/nettles/travel/")
  (vhost "ukiepc.redbrick.dcu.ie" "/webtree/redbrick/ukiepc")
  (vhost "vmweb.redbrick.dcu.ie" "/storage/webtree/w/werdz")
  (vhost "wanderers.redbrick.dcu.ie" "/webtree/w/wander/")
  (vhost "wiki.colmreilly.com" "/webtree/n/nettles/wiki/")
  (vhost "wiki.redbrick.dcu.ie" "/webtree/w/wiki")
  (vhost "www.ejmitchell.com" "/storage/home/member/d/deadlock/ejmitchellcom")
  (vhost "www.iahpc.ie" "/home/guest/iahpc/public_html")
  (vhost "www.luxgaa.lu" "/webtree/s/shivo/LuxGAA")
  (vhost "www.unkle77.com" "/storage/webtree/s/shivo/unkle77/wordpress/")
  (vhost "x-files.redbrick.dcu.ie" "/storage/webtree/f/fox_chic")
  (vhost "yfg.redbrick.dcu.ie" "/storage/webtree/f/finegael")
  (vhost "youth2000.redbrick.dcu.ie" "/storage/webtree/y/youth2k")
  (vhostProxy "jakarta.redbrick.dcu.ie" "http://136.206.15.59:8080")
  (vhostProxy "macspayn.redbrick.dcu.ie" "http://136.206.15.25:3007")
  (vhostProxy "portaldev.redbrick.dcu.ie" "http://136.206.15.61:80:9080")
  (vhostProxy "radio.redbrick.dcu.ie" "http://radio.redbrick.dcu.ie:8000")
  (vhostProxy "radio.theinternets.be" "http://radio.redbrick.dcu.ie:80")
  (vhostProxy "riainccc.redbrick.dcu.ie" "http://http://136.206.15.25:3000")
  (vhostProxy "tomcat.dregin.redbrick.dcu.ie" "http://136.206.15.14:20002")
  (vhostProxy "webchat.redbrick.dcu.ie" "136.206.15.74:9090")
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
]")
