{tld}: {
  # System, committee and important email aliases.
  #
  # NOTES
  # =====
  # - For committee position aliases during the changeover period, list the
  #   outgoing person(s) first followed by the incoming person(s).

  #-----------------#
  # SYSTEM ACCOUNTS #
  #-----------------#

  # Redirections for system and pseudo accounts.
  "MAILER-DAEMON" = "postmaster";
  "postmaster" = "root";
  "bin" = "root";
  "daemon" = "root";
  "man" = "root";
  "news" = "root";
  "nobody" = "/dev/null";
  "operator" = "root";
  "pop" = "root";
  "system" = "root";
  "toor" = "root";
  "usenet" = "news";
  "uucp" = "root";
  "xten" = "root";
  "postfix" = "root";
  "abuse" = "rb-admins,chair,sec";
  "security" = "root";
  "ftp" = "root";
  "ftp-bugs" = "ftp";
  "hostmaster" = "root";
  "nagios" = "root";
  "_nagios" = "root";
  "ossec" = "root";

  # Mailman
  "mailman" = "root";
  "mailman-owner" = "mailman";
  "mailman-request" = "mailman";
  "mailman-bounces" = "mailman";
  "mailman-admin" = "mailman";

  # Where root mail goes. VERY IMPORTANT!
  "root" = "rb-admins";

  #----------------#
  # Administrators #
  #----------------#

  # Who wants to get system reports, cron job output etc.
  "system-reports" = "rb-admins";
  "audit_warn" = "system-reports";

  # Offical way to contact admins for requests.
  "admin-request" = "rb-admins, ticket";
  "elected-admin" = "elected-admins";

  # Where mail addressed to generic 'admins' goes.
  "admin" = "admin-request";
  "admins" = "admin-request";

  # DCU admin list.
  #
  # <plop>: Thu May 28 11:07:05 BST 1998
  "dcu-admin-list" = "rb-admins, sysops@dcu.ie, mcgorman@compapp.dcu.ie";

  # Admin Mailing lists
  "rb-admins" = "rb-admins@lists.${tld}";
  "elected-admins" = "elected-admins@lists.${tld}";
  "admin-discuss" = "admin-discuss@lists.${tld}";
  "trainee-admins" = "trainee-admins@lists.${tld}";

  #-------------#
  # Web related #
  #-------------#

  # webmaster is a mailman list
  "httpd" = "webmaster";
  "www" = "webmaster";
  "webmaster" = "webmaster@lists.${tld}";

  #---------------------#
  # Committee & Society #
  #---------------------#

  # "The Founders" (TM)
  "founders" = "drjolt, wibble, sandman, fergus, swipe, hyper";

  # Committee is a mailing list (handled by mailman)
  "committee" = "committee@lists.${tld}";

  # HELP! requests.
  "help" = "helpdesk";
  "support" = "helpdesk";
  "help-request" = "helpdesk";
  "helpdesk-request" = "helpdesk";
  "helpdesk" = "helpdesk@lists.${tld}";

  # Chairperson alias.
  "chairperson" = "chair";

  # Treasurer alias.
  "treasurer" = "treasure";

  # Secretary alias.
  "secretary" = "sec";

  # Events alias.
  "ents" = "events";
  "birthday" = "events";

  # Accounts alias:
  "accounts" = "elected-admins, treasurer, chair";

  # Redbrick encyclopedia sybmissions/queries.
  #
  # wishkah gave webgroup encylopedia, on conditions he
  # be included in mails about it - <bubble>
  #
  "encyclopedia" = "wishkah";

  # c-hey maintainters alias.
  "c-hey" = "pooka, colmmacc, bobb";

  # DNS.
  "dns" = "committee";

  # cancel-announce
  # Cthulhu Thu Jan 27 01:00:00 GMT 2000
  "cancel-announce" = "bobb";

  #---------------#
  # Miscellaneous #
  #---------------#

  # Mailing List aliases
  "commonroom" = "\"commonroom@lists.${tld}\"";
  "latvia" = "\"latvia@lists.${tld}\"";
  "renting" = "\"rental@lists.${tld}\"";
  # this one is for pooka's mailing list
  "learning-journal" = "learning-journal@lists.${tld}";

  # User aliases
  "wimax" = "johan";
  # Alias for STOCS to go with Web Page URL. (Added cthulhu)
  "sillicon" = "stocs";
  "spamtastic" = "bubble";
  "su-webgroup" = "phil, arioch, p, esoteric";
  "senseigoclub" = "pooka, belial, plop+go";
  "blog" = "atlas";
  "skyhawk" = "declan";
  "tom.doyle" = "greenday";
  "hairforceone" = "greenday";
  "david.craig" = "vexation";
  "dave.murphy" = "drjolt";
  "david.murphy" = "drjolt";
  "s.maher" = "snoopie";
  "Robert.Carew" = "rob";
  "diablo" = "fergus";
  "antarbh" = "supres";
  "colin.whittaker" = "grimnar";
  "meaigs" = "afrodite";
  "Margaret.McGaley" = "afrodite";
  "Kevin.Cannon" = "p";
  "raz" = "ivor";
  "fergusos" = "shocks";
  "zirconia" = "zircon";
  "eoin.mcgrath" = "bob";
  "acahill" = "ace";
  "Ian.Hollingsworth" = "lemming";
  "comet" = "helmet";
  "thomas.kelly" = "kudo";
  "debug" = "ubiquity";
  "webradio" = "kudo, singer, cain, celery, thayl";
  "red_giant" = "redgiant";
  "dong" = "tunney";
  "donal.mulligan" = "thor";
  "donal" = "thor";
  "Tanya.Reilly" = "toaster";
  "mark.dunne" = "pixies";
  "cathal.thorne" = "bodie";
  "lickylips" = "lickylip";
  "youknowwho" = "lickylip";
  "john.canavan" = "tibor";
  "john" = "tibor";
  "john.lyons" = "homerj";
  "brian.scanlan" = "singer";
  "caroline.sheedy" = "bootie";
  "jon.lundberg" = "spock";
  "jonathan.lundberg" = "spock";
  "damien.martin" = "otto";
  "orla.mcgann" = "orly";
  "nigel.parkes" = "elmer";
  "eileen.gavin" = "munchkin";
  "john.looney" = "valen";
  "cian.synnott" = "pooka";
  "mothlamp" = "pooka";
  "kachun.leung" = "plop";
  "dermot.hanley" = "wibble";
  "mike.mchugh" = "sandman";
  "james.raferty" = "lecter";
  "james.raftery" = "lecter";
  "aoife.mcgoveran" = "hms";
  "andrew.lawless" = "andy";
  "shane.ohuid" = "wishkah";
  "daire.mckenna" = "fatwa";
  "john.barker" = "barkerj";
  "sean.cullen" = "hyper";
  "paraic.oceallaigh" = "swipe";
  "micheal.mchugh" = "sandman";
  "fergus.donohue" = "fergus";
  "barry.oneill" = "bubble";
  "aoife.cahill" = "ace";
  "sheila.pollard" = "sheila";
  "robert.crosbie" = "bobb";
  "bobb-spam" = "bobb";
  "bobb-spam0" = "bobb";
  "bobb-spam1" = "bobb";
  "bobb-spam2" = "bobb";
  "bobb-spam3" = "bobb";
  "bobb-spam4" = "bobb";
  "bobb-spam5" = "bobb";
  "bobb-spam6" = "bobb";
  "bobb-spam7" = "bobb";
  "bobb-spam8" = "bobb";
  "bobb-spam9" = "bobb";
  "adam.kelly" = "cthulhu";
  "justin.moran" = "cain";
  "cecily.murray" = "celery";
  "karl.podesta" = "kpodesta";
  "ronan.ryan" = "ledge";
  "johnny" = "jonny";
  "andrew.phillips" = "jesus";
  "hoi.chau.wong" = "whc";
  "paddy.grant" = "floppy";
  "patrick.grant" = "floppy";
  "julie.kerin" = "julie";
  "iddqd" = "macbain";
  "michael.mcginness" = "mikka";
  "conor.okane" = "cokane";
  "donal.hunt" = "redgiant";
  "brian.bambrick" = "moridin";
  "declan.brennan" = "wilma";
  "grainne.walsh" = "grainy";
  "philip.reynolds" = "phil";
  "phil.reynolds" = "phil";
  "mglennon" = "magluby";
  "sigh" = "mort";
  "mort" = "arioch";
  "craygor" = "element";
  "ledg" = "ledge";
  "amanda" = "dipso";
  "djhooker" = "wilma";
  "dell" = "sandman";
  "patsy" = "heavenly";
  "raf" = "turiel";
  "littlemisscomedy" = "lmc";
  "samresh" = "doomgod";
  "conor.coyle" = "squaw";
  "kevinbrennan" = "zircon";
  "alanthecat" = "alantc";
  "colm.maccarthaigh" = "colmmacc";
  "pizzateam" = "sonic";
  "holyspambatman" = "sonic";
  "david.johnston" = "emperor";
  "dermot.duffy" = "dizer";
  "dizerspam" = "dizer";
  "eoin.campbell" = "cambo";
  "neil.walsh" = "marvin";
  "barry" = "bubble";
  "anthony.moyles" = "huey";
  "mclarke" = "prolix";
  "mclark" = "prolix";
  "mark_campbell" = "mark";
  "mark.campbell" = "mark";
  "mcampbell" = "mark";
  "campbellm" = "mark";
  "pronane" = "kaos";
  "shane_tallon" = "del_boy";
  "wesley.gorman" = "badboy";
  "ciaran.kenny" = "goratrix";
  "trevor.johnston" = "trevj";
  "sinead.mcgivney" = "neady";
  "enda_dowling" = "deano";
  "david.concannon" = "shimoda";
  "gary_ludgate" = "dice";
  "martin.clarke" = "prolix";
  "cambo1982" = "cambo";
  "jonathan.walsh" = "melmoth";
  "ann.byrne" = "halfpint";
  "martin.harte" = "tuama";
  "lee.cash" = "brodie";
  "declan.oneill" = "dec";
  "keith.mcdonnell" = "bkeeper";
  "john.ruddy" = "phase";
  "peter.sinnott" = "link";
  "michael.dowling" = "mickeyd";
  "mickeydspam" = "mickeyd";
  "eoghan" = "atlas";
  "dru" = "drusilla";
  "wavehunt" = "johan";
  "stephen.ryan37" = "ryaner";
  "natashamaher" = "7of9";
  "huskerdu" = "phl";
  "credak" = "creadak";
  "craig.gavagan" = "creadak";
  "joeh762" = "kuze";
  "macattac" = "mak";
  "failho" = "carri";
  "bunny" = "bunbun";
  # This burd wanted this alias. She's a friend of mine (singer).
  # She used to be these addresses. Get rid of them and you're
  # all dead. Yes, even you, son of drjolt in the year 2525.
  # ok boomer - m1cr0man, 2020
  "zorro" = "\"Aisling.NiCheallachain@irishlife.ie\"";
  "aisfc" = "\"Aisling.NiCheallachain@irishlife.ie\"";
  "assassins" = "art_wolf";
  "sarunas" = "svan";
  "sarunas.v" = "svan";
  "sarunas.vancevicius" = "svan";
  "eoghan.gaffney" = "atlas";
  "carbonkid" = "gaara";
  "waf" = "dregin";
  "surfnsail" = "sailing";
  "andrew.martin" = "werdz";
  "mieows" = "angelkat";
  "cocowtf" = "cocao";
  "patrickswayze" = "goldfish";
  "wolfhead" = "drg";
  "david.lynam" = "coconut";
  "cian.brennan" = "lil_cain";
  "cian" = "lil_cain";
  "biggestpenis" = "lil_cain";
  "eoghan.cotter" = "johan";
  "austin.halpin" = "haus";
  "shane.stacey" = "isaac702";
  "fruitcake" = "fructus";
  "fruitcaek" = "fructus";
  "lotta.mikkonen" = "attol";
  "diarmaid.mcmanus" = "elephant";
  "caroline.fuery" = "carri";
  "damien.rhatigan" = "dano";
  "jennifer.flynn" = "jennyf";
  "michael.odowd" = "nanaki";
  "microman" = "m1cr0man";
  "cian.butler" = "butlerx";
  # guess which one is the correct one
  "kat.farrell" = "angelkat";
  "kat.farrel" = "angelkat";
  "kat.farell" = "angelkat";
  "kat.farel" = "angelkat";
  #for sonic
  "alan.walsh" = "sonic";
  "alwalsh" = "sonic";
  "alanwalsh" = "sonic";
  "sonicthehedgehog" = "sonic";
  # aliases for receive :)
  "andrew.harford" = "receive";
  "andrew.j.harford" = "receive";
  "andy.harford" = "receive";
  "winchair" = "angelkat";
  "winkat" = "angelkat";
  "starbuck" = "receive";
  # people spell bad
  "recieve" = "receive";
  "andrew.hartford" = "receive";
  "lotta" = "attol";
  "powertax" = "pwrtaxi";

  "gamestocs" = "gamessoc";
  "games1" = "gamessoc";
  "games2" = "gamessoc";
  "gamessoc1" = "gamessoc";
  "gamessoc2" = "gamessoc";
  "gamessoc3" = "gamessoc";
  "gamessoc4" = "gamessoc";
  "gamessoc5" = "gamessoc";
  "gamessoc6" = "gamessoc";
  "gamessoc7" = "gamessoc";
  "gamessoc8" = "gamessoc";
  "gamessoc9" = "gamessoc";
  "gamessoc10" = "gamessoc";
  "gamessoc11" = "gamessoc";
  "gamessoc12" = "gamessoc";
  "gamessoc13" = "gamessoc";

  "jennyf" = "ribbons";
  "niall.gaffney" = "gamma";
  "richard.walsh" = "koffee";
  "vadim" = "vadimck";
  "lorcan.boyle" = "zergless";
  "robert.devereux" = "kylar";
  "christopher.boyle" = "greyman";
  "cboyle" = "greyman";
  "cliodhna.harrison" = "thegirl";
  "safrole" = "saf";
  "jonny" = "banjo";
  "xmeabhx" = "timelady";
  "jamesreilly" = "fun";
  "snowda" = "fordy";
  "funtrain" = "admins";
  "ladmins" = "admins";
  "tron" = "jammy";
  "amadan" = "marvin";
  "mike_d" = "marvin";
  "loky" = "chikatee";
  "scunni" = "jericho";
  "the_rock" = "jericho";
  "iruane" = "stark";
  "aurora" = "smf";
  "smithers" = "manuel";
  "jonnyb" = "nedd";
  "wwallace" = "epic";
  "lizard" = "creech";
  "lep" = "phat";
  "crispy" = "chris";
  "account" = "afsoc";
  "odie" = "me";
  "hriding" = "equest";
  "equestrian" = "equest";

  "economosoc" = "econosoc";

  # now a spamtrap - colmmacc
  "sarahb" = "/dev/null";
  "audi_58" = "AUDI_S8";
  "c_clay" = "fallen";
  "rcummi" = "4aces";
  "imelda" = "fruity";
  "mulinho" = "mullins";
  "sully1" = "sully";
  "robert" = "gandalf";
  "d_omall" = "domall";
  "dhunt" = "zoro";
  "seth" = "stranger";
  "jolt-9" = "chalk";
  "gee_sus" = "gee";
  "jruddy" = "phase";
  "lynchman" = "mloc";
  "brianh" = "alantc";
  "sutty" = "yosarian";
  "ryanks" = "rhino";
  "aliastom" = "ayatolah";
  "osprey" = "pariah";
  "jbolger" = "x";
  "joey_p" = "mrs_girl";
  "vigdis" = "tom";
  "dimitri" = "grover";
  "oasis" = "geezer";
  "games" = "gamessoc";
  "smeghead" = "jeebers";
  "piesoc" = "matsoc";
  "cherub" = "crumbs";
  "dme3" = "dme4";
  "garyod2" = "gary";
  "haus17" = "haus";
  "nadned" = "damnson";
}
