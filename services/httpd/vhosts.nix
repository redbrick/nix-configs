let
  vhost = hostName: documentRoot: {
    inherit hostName documentRoot;
    serverAliases = [ "www.${hostName}" ];
    extraConfig = ''
      Options ExecCGI Includes Indexes SymLinksIfOwnerMatch

      AddHandler cgi-script .cgi
      AddHandler cgi-script .py
      AddHandler x-httpd-php .php
      AddHandler cgi-script .sh
      AddHandler cgi-script .pl
      AddHandler server-parsed .shtml
      AddHandler server-parsed .html

      AddType text/html .shtml
    '';
  };
  vhostRedirect = hostName: globalRedirect: {
    inherit hostName globalRedirect;
    serverAliases = [ "www.${hostName}" ];
  };
in [
  (vhost "abovethefold.es" "/webtree/r/receive/abovethefold")
  (vhost "bash.redbrick.dcu.ie" "/webtree/y/yosarian/bash")
  (vhost "blog.lessthanthree.be" "/webtree/o/ornat/blog")
  (vhost "boards.redbrick.dcu.ie" "/storage/webtree/b/boards")
  (vhost "bricket.redbrick.dcu.ie" "/storage/webtree/w/werdz/bricket")
  (vhost "brickjet.redbrick.dcu.ie" "/storage/webtree/j/johan/brickjet")
  (vhost "bugzilla.redbrick.dcu.ie" "/storage/webtree/vhosts/bugzilla.redbrick.dcu.ie")
  (vhost "butterflyexplosion.com" "/webtree/c/carr")
  (vhost "ciankehoe.ie" "/webtree/c/cianky/ciankehoe.ie/public/")
  (vhost "cmtwiki.redbrick.dcu.ie" "/webtree/redbrick/htdocs/cmt/wiki")
  (vhost "dcudrama.ie" "/webtree/d/drama")
  (vhost "dcufm.redbrick.dcu.ie" "/var/www/apache2-default/")
  (vhost "djbdns.now.ie" "/home/associat/l/lecter/public_html/djbdns")
  (vhostRedirect "events.redbrick.dcu.ie" "https://redbrick.dcu.ie/events")
  (vhost "freedom.redbrick.dcu.ie" "/storage/webtree/b/bunbun")
  (vhostRedirect "fosdem.redbrick.dcu.ie" "https://redbrickdcu.typeform.com/to/ZwETj0")
  (vhostRedirect "github.redbrick.dcu.ie" "https://github.com/redbrick")
  (vhost "grahambartley.com" "/webtree/d/dedoctor/")
  (vhost "h8.work" "/webtree/a/ainran/domains/h8.work")
  (vhost "halenger.com" "/home/associat/h/halenger/domains/halenger.com")
  (vhostRedirect "helpdeskexam.redbrick.dcu.ie" "https://md.redbrick.dcu.ie/s/SJzip7F9X#")
  (vhost "hg.redbrick.dcu.ie" "/storage/webtree/hg")
  (vhostRedirect "hoodies.redbrick.dcu.ie" "https://redbrickdcu.typeform.com/to/Q4uIzR")
  ("jakarta.redbrick.dcu.ie")
  (vhost "lessthanthree.be" "/webtree/o/ornat")
  ("macspayn.redbrick.dcu.ie")
  (vhost "mcmahon.redbrick.dcu.ie" "/webtree/m/mcmahon/wordpress")
  (vhost "mlane.org" "/webtree/a/ainran/mlane")
  (vhost "obrienronan.com" "/webtree/vhosts/www.obrienronan.com")
  (vhost "openid.redbrick.dcu.ie" "/storage/webtree/o/openid")
  (vhost "packages.redbrick.dcu.ie" "/webtree/r/rbpkg/apt")
  (vhost "pkmn.redbrick.dcu.ie" "/storage/webtree/k/koffee/pkmn")
  ("portaldev.redbrick.dcu.ie")
  ("radio.redbrick.dcu.ie")
  ("radio.theinternets.be")
  (vhost "rbvm.redbrick.dcu.ie" "/webtree/vhosts/rbvm.redbrick.dcu.ie")
  ("riainccc.redbrick.dcu.ie")
  (vhost "richardwalsh.ie" "/storage/webtree/k/koffee/")
  (vhost "romana.now.ie" "/home/associat/l/lecter/public_html")
  (vhost "rtd.redbrick.dcu.ie" "/webtree/redbrick/extras/RFCs/build/html")
  (vhost "ryanmcdyer.com" "/webtree/r/ryanmcd")
  ("sentriz.redbrick.dcu.ie")
  (vhost "shaunneary.com" "/storage/webtree/s/shaun/koken")
  (vhost "solarsystemscanlan.com" "/webtree/s/singer/solarsystemscanlan.com/")
  (vhost "songsfromtheparlour.com" "/webtree/vhosts/www.songsfromtheparlour.com")
  (vhost "speakeasyireland.ie" "/webtree/s/spkeasy")
  (vhost "techweek.dcu.ie" "/webtree/t/techwk/dist")
  (vhost "thecollegeview.com" "/webtree/p/pubsoc")
  (vhost "theinternets.be" "/var/www/r/receive/internets" "/var/www/r/receive/blog" "/var/www/r/receive" "/var/www/r/receive/wrong")
  (vhost "thelookdcu.com" "/storage/webtree/t/thelook/")
  (vhost "theparachichi.com" "/webtree/v/vmuia")
  ("tickets.redbrick.dcu.ie")
  ("tomcat.dregin.redbrick.dcu.ie")
  (vhost "travel.colmreilly.com" "/webtree/n/nettles/travel/")
  (vhost "ukiepc.redbrick.dcu.ie" "/webtree/redbrick/ukiepc")
  (vhost "vmweb.redbrick.dcu.ie" "/storage/webtree/w/werdz")
  (vhost "wanderers.redbrick.dcu.ie" "/webtree/w/wander/")
  ("webchat.redbrick.dcu.ie")
  ("werdztomcat.redbrick.dcu.ie")
  (vhost "wiki.colmreilly.com" "/webtree/n/nettles/wiki/")
  (vhost "wiki.redbrick.dcu.ie" "/webtree/w/wiki")
  (vhost "www.ejmitchell.com" "/storage/home/member/d/deadlock/ejmitchellcom")
  (vhost "www.iahpc.ie" "/home/guest/iahpc/public_html")
  (vhost "www.luxgaa.lu" "/webtree/s/shivo/LuxGAA")
  (vhost "www.unkle77.com" "/storage/webtree/s/shivo/unkle77/wordpress/")
]
