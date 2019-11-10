{ config, ... }:
let
  common = import ../../common/variables.nix;
  users = import ./users.nix;

  webtree = common.webtreeDir;
  home = common.homesDir;
  tld = common.tld;
  adminAddr = "webmaster@${tld}";

  vhost = hostName: documentRoot: {
    inherit hostName documentRoot adminAddr;
    enableSSL = true;
    serverAliases = [ "www.${hostName}" ];
  };

  vhostRedirect = hostName: globalRedirect: {
    inherit hostName globalRedirect adminAddr;
    enableSSL = true;
    serverAliases = [ "www.${hostName}" ];
  };

  vhostProxy = hostName: proxyAddress: {
    inherit hostName adminAddr;
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

  # This is appended at the bottom
  # to ensure that custom vhosts take preference
  userVhosts = builtins.map (user: let
    documentRoot = common.userWebtree user.uid;
  in {
    inherit documentRoot adminAddr;
    hostName = "${user.uid}.${tld}";
    enableSSL = true;
    extraConfig = ''
      <Directory "${documentRoot}">
        AllowOverride AuthConfig FileInfo Indexes Limit AuthConfig Options=ExecCGI,Includes,IncludesNoExec,Indexes,MultiViews,SymlinksIfOwnerMatch
        Require all granted
      </Directory>

      <FilesMatch \.php\d*$>
        SetHandler "proxy:unix:/run/phpfpm/${user.uid}.sock|fcgi://localhost/"
      </FilesMatch>

      SuExecUserGroup ${user.uid} ${user.gid}
    '';
  }) users;
in [
  (vhost "abovethefold.es" "${webtree}/r/receive/abovethefold")
  (vhost "admins.${tld}" "${webtree}/vhosts/admins.redbrick.dcu.ie")
  (vhost "alanwalsh.${tld}" "${webtree}/s/sonic/cv")
  (vhost "assassins.${tld}" "${webtree}/a/art_wolf/assassins")
  (vhost "astro.${tld}" "${webtree}/k/k100/astro")
  (vhost "birthday.${tld}" "${webtree}/s/space/Redbrick-Turns-20/resources/public")
  (vhost "blog.lessthanthree.be" "${webtree}/o/ornat/blog")
  (vhost "bricket.${tld}" "${webtree}/w/werdz/bricket")
  (vhost "brickjet.${tld}" "${webtree}/j/johan/brickjet")
  (vhost "bugzilla.${tld}" "${webtree}/vhosts/bugzilla.redbrick.dcu.ie")
  (vhost "butterflyexplosion.com" "${webtree}/c/carr")
  (vhost "ca2wiki.${tld}" "${webtree}/s/sonic/wiki")
  (vhost "ca3wiki.${tld}" "${webtree}/s/sonic/wikica3")
  (vhost "ca4wiki.${tld}" "${webtree}/s/sonic/ca4wiki")
  (vhost "ciankehoe.ie" "${webtree}/c/cianky/ciankehoe.ie/public/")
  (vhost "cmtwiki.${tld}" "${webtree}/redbrick/htdocs/cmt/wiki")
  (vhost "colors.${tld}" "${webtree}/vhosts/colors.redbrick.dcu.ie")
  (vhost "committee.${tld}" "${webtree}/c/chair/blog")
  (vhost "dcudrama.ie" "${webtree}/d/drama")
  (vhost "dcufm.${tld}" "${webtree}/apache2-default/")
  (vhost "dibs.${tld}" "${webtree}/d/dever/dibs")
  (vhost "djbdns.now.ie" "${home}/associat/l/lecter/public_html/djbdns")
  (vhost "forbidden.${tld}" "${webtree}/vhosts/forbidden.redbrick.dcu.ie")
  (vhost "forgottofollow.${tld}" "${webtree}/m/mick")
  (vhost "freedom.${tld}" "${webtree}/b/bunbun")
  (vhost "gallery.${tld}" "${webtree}/g/gallery")
  (vhost "grahambartley.com" "${webtree}/d/dedoctor/")
  (vhost "h8.work" "${webtree}/a/ainran/domains/h8.work")
  (vhost "hack.${tld}" "${webtree}/n/newbrick")
  (vhost "hackaton.${tld}" "${webtree}/n/newbrick")
  (vhost "halenger.com" "${home}/associat/h/halenger/domains/halenger.com")
  (vhost "interlan.${tld}" "${webtree}/vhosts/www.interlan.dcu.ie")
  (vhost "lessthanthree.be" "${webtree}/o/ornat")
  (vhost "mak.${tld}" "${webtree}/m/mak/mak")
  (vhost "mcmahon.${tld}" "${webtree}/m/mcmahon/wordpress")
  (vhost "mlane.org" "${webtree}/a/ainran/mlane")
  (vhost "n109a.${tld}" "${webtree}/e/edu/n109a")
  (vhost "nemo.${tld}" "${webtree}/n/nemo/wordpress")
  (vhost "obrienronan.com" "${webtree}/vhosts/www.obrienronan.com")
  (vhost "openid.${tld}" "${webtree}/o/openid")
  (vhost "packages.${tld}" "${webtree}/r/rbpkg/apt")
  (vhost "paintball.${tld}" "${webtree}/p/paintbal")
  (vhost "performingarts.${tld}" "${webtree}/p/perfarts")
  (vhost "pkmn.${tld}" "${webtree}/k/koffee/pkmn")
  (vhost "pleasetalkredbrick.dcu.ie" "${webtree}/p/plstalk")
  (vhost "profiles.${tld}" "${webtree}/d/d_fens/profiles")
  (vhost "rbvm.${tld}" "${webtree}/vhosts/rbvm.redbrick.dcu.ie")
  (vhost "richardwalsh.ie" "${webtree}/k/koffee/")
  (vhost "romana.now.ie" "${home}/associat/l/lecter/public_html")
  (vhost "room.${tld}" "${webtree}/e/edu/n109a")
  (vhost "rtd.${tld}" "${webtree}/redbrick/extras/RFCs/build/html")
  (vhost "ryanmcdyer.com" "${webtree}/r/ryanmcd")
  (vhost "sadsoc.${tld}" "${webtree}/a/art_wolf/sadsoc")
  (vhost "security.${tld}" "${webtree}/d/d_fens/security")
  (vhost "shaunneary.com" "${webtree}/s/shaun/koken")
  (vhost "signup.${tld}" "${webtree}/e/events/csday")
  (vhost "solarsystemscanlan.com" "${webtree}/s/singer/solarsystemscanlan.com/")
  (vhost "songsfromtheparlour.com" "${webtree}/vhosts/www.songsfromtheparlour.com")
  (vhost "speakeasyireland.ie" "${webtree}/s/spkeasy")
  (vhost "surfnsail.${tld}" "${webtree}/s/sailing")
  (vhost "techweek.dcu.ie" "${webtree}/t/techwk/dist")
  (vhost "thecollegeview.com" "${webtree}/p/pubsoc")
  (vhost "theinternets.be" "${webtree}/r/receive/internets")# "/var/www/r/receive/blog" "/var/www/r/receive" "/var/www/r/receive/wrong")
  (vhost "thelookdcu.com" "${webtree}/t/thelook/")
  (vhost "theparachichi.com" "${webtree}/v/vmuia")
  (vhost "travel.colmreilly.com" "${webtree}/n/nettles/travel/")
  (vhost "ukiepc.${tld}" "${webtree}/redbrick/ukiepc")
  (vhost "vmweb.${tld}" "${webtree}/w/werdz")
  (vhost "wanderers.${tld}" "${webtree}/w/wander/")
  (vhost "wiki.colmreilly.com" "${webtree}/n/nettles/wiki/")
  ((vhost "wiki.${tld}" "${webtree}/w/wiki") // {
    extraConfig = ''
      SuExecUserGroup wiki redbrick
      <FilesMatch \.php\d*$>
        SetHandler "proxy:unix:/run/phpfpm/wiki.sock|fcgi://localhost/"
      </FilesMatch>
    '';
  })
  (vhost "ejmitchell.com" "${home}/member/d/deadlock/ejmitchellcom")
  (vhost "iahpc.ie" "${home}/guest/iahpc/public_html")
  (vhost "luxgaa.lu" "${webtree}/s/shivo/LuxGAA")
  (vhost "unkle77.com" "${webtree}/s/shivo/unkle77/wordpress/")
  (vhost "x-files.${tld}" "${webtree}/f/fox_chic")
  (vhost "yfg.${tld}" "${webtree}/f/finegael")
  (vhost "youth2000.${tld}" "${webtree}/y/youth2k")
  (vhostProxy "jakarta.${tld}" "http://136.206.15.59:8080")
  (vhostProxy "macspayn.${tld}" "http://136.206.15.25:3007")
  (vhostProxy "portaldev.${tld}" "http://136.206.15.61:9080")
  (vhostProxy "radio.${tld}" "http://radio.redbrick.dcu.ie:8000")
  (vhostProxy "riainccc.${tld}" "http://http://136.206.15.25:3000")
  (vhostProxy "tomcat.dregin.${tld}" "http://136.206.15.14:20002")
  (vhostProxy "webchat.${tld}" "http://136.206.15.74:9090")
  (vhostProxy "werdztomcat.${tld}" "http://136.206.15.14:20001")
  (vhostRedirect "admin.${tld}" "https://admins.redbrick.dcu.ie")
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
