{config, lib, ...}:
let
  tld = config.redbrick.tld;
  ipAddress = config.redbrick.ircServerAddress;
  common = import ../../common/variables.nix;
in {
  server = {
    "irc.${tld}" = {
      description = "Redbrick intersocs node";
      network = "Intersocs";
      id = "1RB";
    };
  };
  admin = {
    "Redbrick Intersocs Server IRC admin" = {
      nick = "Admins";
      email = "admins@${tld}";
    };
  };

  bind = [
    {
      address = ""; # ipAddress;
      port = "6697";
      ssl = "openssl";
      type="clients";
    }
    {
      address = ""; # ipAddress;
      port = "7001";
      ssl = "openssl";
      type = "servers";
    }
  ];

  connect = {
    Secure = {
      parent="Main";
      port="6697";
    };
    Main = {
      allow ="*";
      hash="sha256";
      timeout="10";
      limit="5000";
    };
  };
  cidr = [{
    ipv4clone="32";
    ipv6clone="128";
  }];
  class = {
    Shutdown = {
      commands="DIE RESTART REHASH LOADMODULE UNLOADMODULE RELOADMODULE GLOADMODULE GUNLOADMODULE GRELOADMODULE";
      privs="users/auspex channels/auspex servers/auspex users/mass-message channels/high-join-limit users/flood/no-throttle users/flood/increased-buffers";
      usermodes="*";
      chanmodes="*";
    };
    SACommands = {
      commands="SAJOIN SAPART SANICK SAQUIT SATOPIC SAKICK SAMODE OJOIN";
    };
    ServerLink = {
      commands="CONNECT SQUIT RCONNECT RSQUIT MKPASSWD ALLTIME SWHOIS JUMPSERVER LOCKSERV UNLOCKSERV";
      usermodes="*";
      chanmodes="*";
      privs="servers/auspex";
    };
    BanControl = {
      commands="KILL GLINE KLINE ZLINE QLINE ELINE TLINE RLINE CHECK NICKLOCK NICKUNLOCK SHUN CLONES CBAN";
      usermodes="*";
      chanmodes="*";
    };
    OperChat = {
      commands="WALLOPS GLOBOPS";
      usermodes="*";
      chanmodes="*";
      privs="users/mass-message";
    };
    HostCloak = {
      commands="SETHOST SETIDENT SETIDLE CHGNAME CHGHOST CHGIDENT";
      usermodes="*";
      chanmodes="*";
      privs="users/auspex";
    };
  };
  type = {
    NetAdmin = {
      classes="SACommands OperChat BanControl HostCloak Shutdown ServerLink";
      modes="+s +cCqQ";
    };
  };
  oper = {
    butlerx = {
      hash="hmac-sha256";
      # password: A hash of the password (see above option) hashed
      # with /mkpasswd <hash> <password>. See m_password_hash in modules.conf
      # for more information about password hashing.
      password=lib.fileContents /var/secrets/ircd/butlerx.sha256.pass;
      host="*@*";
      sslonly="yes";
      type="NetAdmin";
    };
  };
  files = [{
    motd = ./motd.txt;
    rules = ./rules.txt;
  }];
  channels = [{
    users = "80";
    opers = "600";
  }];
  dns = [{
    server = builtins.head config.networking.nameservers;
    timeout = "5";
  }];
  options = [{
    prefixquit="Quit: ";
    suffixquit="";
    prefixpart="&quot;";
    suffixpart="&quot;";
    syntaxhints="yes";
    cyclehosts="yes";
    cyclehostsfromuser="no";
    ircumsgprefix="no";
    announcets="yes";
    allowmismatch="no";
    defaultbind="auto";
    hostintopic="yes";
    pingwarning="15";
    serverpingfreq="60";
    defaultmodes="nt";
    moronbanner="You're banned! Email abuse@redbrick.dcu.ie if you feel this is wrongly justified";
    exemptchanops="nonick:v flood:o";
    invitebypassmodes="yes";
    nosnoticestack="no";
    welcomenotice="yes";
  }];
  performance = [{
    netbuffersize="10240";
    somaxconn="128";
    limitsomaxconn="true";
    softlimit="12800";
    quietbursts="yes";
    nouserdns="no";
  }];
  security = [{
    announceinvites="dynamic";
    hidemodes="eI";
    hideulines="no";
    flatlinks="no";
    hidewhois="";
    hidebans="no";
    hidekills="";
    hideulinekills="yes";
    hidesplits="no";
    maxtargets="20";
    customversion="";
    operspywhois="no";
    restrictbannedusers="yes";
    genericoper="no";
    userstats="Pu";
  }];
  limits = [{
    maxnick="31";
    maxchan="64";
    maxmodes="20";
    maxident="11";
    maxquit="255";
    maxtopic="307";
    maxkick="255";
    maxgecos="128";
    maxaway="200";
  }];
  whowas = [{
    groupsize="10";
    maxgroups="100000";
    maxkeep="3d";
  }];
  badnick = [
    {
      nick="ChanServ";
      reason="Reserved For Services";
    }
    {
      nick="NickServ";
      reason="Reserved For Services";
    }
    {
      nick="OperServ";
      reason="Reserved For Services";
    }
    {
      nick="MemoServ";
      reason="Reserved For Services";
    }
    {
      nick="root";
      reason="Don't IRC as root!";
    }
  ];
  insane = [{
    hostmasks="no";
    ipmasks="no";
    nickmasks="no";
    trigger="95.5";
  }];
  module = {
    "m_sha256.so" = {};
    "m_alias.so" = {};
    "m_alltime.so" = {};
    "m_banexception.so" = {};
    "m_banredirect.so" = {};
    "m_botmode.so" = {};
    "m_chanhistory.so" = {};
    "m_check.so" = {};
    "m_chgident.so" = {};
    "m_chgname.so" = {};
    "m_clones.so" = {};
    "m_conn_join.so" = {};
    "m_cycle.so" = {};
    "m_customprefix.so" = {};
    "m_ldapauth.so" = {};
    "m_operjoin.so" = {};
    "m_operlog.so" = {};
    "m_operprefix.so" = {};
    "m_opermodes.so" = {};
    "m_passforward.so" = {};
    "m_password_hash.so" = {};
    "m_muteban.so" = {};
    "m_randquote.so" = {};
    "m_regex_glob.so" = {};
    "m_regex_posix.so" = {};
    "m_remove.so" = {};
    "m_rline.so" = {};
    "m_sakick.so" = {};
    "m_samode.so" = {};
    "m_satopic.so" = {};
    "m_serverban.so" = {};
    "m_sslmodes.so" = {};
    "m_timedbans.so" = {};
    "m_uninvite.so" = {};
    "m_ssl_openssl.so" = {};
    "m_spanningtree.so" = {};
  };
  customprefix = {
    halfop = {
      letter="h";
      prefix="%";
      rank="20000";
      ranktoset="30000";
      depriv="yes";
    };
  };
  alias = [
    {
      text="NICKSERV";
      replace="PRIVMSG NickServ :$2-";
      requires="NickServ";
      uline="yes";
    }
    {
      text="CHANSERV";
      replace="PRIVMSG ChanServ :$2-";
      requires="ChanServ";
      uline="yes";
    }
    {
      text="OPERSERV";
      replace="PRIVMSG OperServ :$2-";
      requires="OperServ";
      uline="yes";
      operonly="yes";
    }
    {
      text="NS";
      replace="PRIVMSG NickServ :$2-";
      requires="NickServ";
      uline="yes";
    }
    {
      text="CS";
      replace="PRIVMSG ChanServ :$2-";
      requires="ChanServ";
      uline="yes";
    }
    {
      text="OS";
      replace="PRIVMSG OperServ :$2-";
      requires="OperServ";
      uline="yes";
      operonly="yes";
    }
    {
      text="ID";
      format="#*";
      replace="PRIVMSG ChanServ :IDENTIFY $2 $3";
      requires="ChanServ";
      uline="yes";
    }
    {
      text="ID";
      replace="PRIVMSG NickServ :IDENTIFY $2";
      requires="NickServ";
      uline="yes";
    }
    {
      text="NICKSERV";
      format=":IDENTIFY *";
      replace="PRIVMSG NickServ :IDENTIFY $3-";
      requires="NickServ";
      uline="yes";
    }
    {
      text="CS";
      usercommand="no";
      channelcommand="yes";
      replace="PRIVMSG ChanServ :$1 $chan $2-";
      requires="ChanServ";
      uline="yes";
    }
  ];
  chanhistory = [{
    maxlines="20";
    notice="yes";
  }];
  autojoin = [{ channel="#lobby,#helpdesk"; }];
  ldapauth = [{
    baserdn="ou=accounts,o=redbrick";
    attribute="uid";
    server="ldap://ldap.internal";
    # The allowpattern value allows you to specify a wildcard mask which
    # will always be allowed to connect regardless of if they have an account
    killreason="Access denied, User not in LDAP";
    searchscope="subtree";
    binddn="cn=inspircd,ou=reserved,o=redbrick";
    bindauth=/var/secrets/ircd/ldap.secret;
  }];
  # ldapwhitelist indicates that clients connecting from an IP in the
  # provided CIDR do not need to authenticate against LDAP. It can be
  # repeated to whitelist multiple CIDRs.
  ldapwhitelist = [
    { cidr="178.62.221.152/32"; } # oldsoc.net
    { cidr="136.206.15.0/24"; } # Redbrick.dcu.ie
  ];

  operjoin = [{
    channel="#interadmin";
    override="no";
  }];
  operprefix = [{ prefix="!"; }];
  passforward = [{
    nick="NickServ";
    forwardmsg="NOTICE $nick :*** Forwarding PASS to $nickrequired";
    cmd="PRIVMSG $nickrequired :IDENTIFY $pass";
  }];
  randquote = [{ file=./quotes.txt; }];
  openssl = [{
    certfile = "${common.certsDir}/irc.${tld}/fullchain.pem";
    keyfile = "${common.certsDir}/irc.${tld}/key.pem";
    dhfile = config.security.dhparams.params.ircd.path;
    hash="sha1";
    sslv1="false";
    tlsv1="false";
  }];

  uline = [ { server="services.localhost.net"; silent="yes"; } ];
  link = {
    "services.${tld}" = {
      ipaddr="127.0.0.1";
      port="7000";
      sid="3AX";
      allowmask="127.0.0.0/8";
      sendpass="iamalive";
      recvpass="iamalive";
    };
    # "irc.skynet.ie" = {
    #   allowmask = "193.1.99.82";
    #   ipaddr="193.1.99.82";
    #   port="6667";
    #   allowmask="*";
    #   timeout="15";
    #   ssl="openssl";
    #   hidden="no";
    #   sendpass=/var/secrets/ircd/skynet.send.pass;
    #   recvpass=/var/secrets/ircd/skynet.recv.pass;
    # };
    # "netsoc.co" = {
    #   allowmask = "84.39.234.50";
    #   ipaddr = "84.39.234.50";
    #   port = "6667";
    #   allowmask="*";
    #   timeout="15";
    #   ssl="openssl";
    #   hidden="no";
    #   sendpass=/var/secrets/ircd/netsoc_co.send.pass;
    #   recvpass=/var/secrets/ircd/netsoc_co.recv.pass;
    # };
    # "irc2.netsoc.tcd.ie" = {
    #   allowmask = "134.226.83.*";
    #   ipaddr = "134.226.83.61";
    #   port = "6667";
    #   allowmask="*";
    #   timeout="15";
    #   ssl="openssl";
    #   hidden="no";
    #   sendpass=/var/secrets/ircd/netsoc_tcd.send.pass;
    #   recvpass=/var/secrets/ircd/netsoc_tcd.recv.pass;
    # };
  };
}
