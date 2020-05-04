{pkgs}:
with pkgs.stdenv;
let

  # These scripts are used by the imapsieve plugin to learn spam and ham
  learnSpamScript = pkgs.writeShellScript "learn-spam.sh" ''
    ${pkgs.rspamd}/bin/rspamc -h /run/rspamd/rspamd.sock learn_spam
  '';

  learnHamScript = pkgs.writeShellScript "learn-ham.sh" ''
    ${pkgs.rspamd}/bin/rspamc -h /run/rspamd/rspamd.sock learn_ham
  '';

  sievePipeBinaries = mkDerivation {
    name = "sieve-pipe-binaries";

    phases = [ "copyPhase" "fixupPhase" ];

    copyPhase = ''
      mkdir -p $out/bin
      cp -a ${learnHamScript} $out/bin/learn-ham.sh
      cp -a ${learnSpamScript} $out/bin/learn-spam.sh
    '';
  };

  # sieve-before script to put spam into Junk folder
  spamFilter = pkgs.writeText "spam-filter.sieve" ''
    require ["fileinto"];

    if header :is "X-Spam" "Yes" {
      fileinto "Junk";
    }
  '';

  # imapsieve script to detect when a user marks an email as spam
  reportSpamFilter = pkgs.writeText "report-spam.sieve" ''
    require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables"];

    if environment :matches "imap.email" "*" {
      set "email" "''${1}";
    }

    pipe :copy "learn-spam.sh" [ "''${email}" ];
  '';

  # imapsieve script to detect when a user moves an email out of spam
  reportHamFilter = pkgs.writeText "report-ham.sieve" ''
    require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables"];

    if environment :matches "imap.mailbox" "*" {
      set "mailbox" "''${1}";
    }

    if string "''${mailbox}" "Trash" {
      stop;
    }

    if environment :matches "imap.email" "*" {
      set "email" "''${1}";
    }

    pipe :copy "learn-ham.sh" [ "''${email}" ];
  '';

  sieveSimpleConfig = ''
    sieve_plugins = sieve_imapsieve sieve_extprograms
    sieve_global_extensions = +vnd.dovecot.pipe
    sieve_pipe_bin_dir = ${sievePipeBinaries}/bin
  '';

  sieveCompileConfig = pkgs.writeText "sieve-compile-config" ''
    plugin {
    ${sieveSimpleConfig}
    }
  '';

  sieveScripts = mkDerivation {
    name = "sieve-scripts";

    buildInputs = [ pkgs.dovecot_pigeonhole ];

    phases = [ "copyPhase" ];

    copyPhase = ''
      mkdir -p $out/{before,after,imap}
      cd $out/before
      cp ${spamFilter} spam-filter.sieve
      sievec -c "${sieveCompileConfig}" spam-filter.sieve
      cd $out/imap
      cp ${reportSpamFilter} report-spam.sieve
      cp ${reportHamFilter} report-ham.sieve
      sievec -c "${sieveCompileConfig}" report-spam.sieve
      sievec -c "${sieveCompileConfig}" report-ham.sieve
    '';

    meta = with lib; {
      description = "Redbrick compiled sieve scripts for Dovecot";
      platforms = platforms.linux;
      maintainers = [ maintainers.m1cr0man ];
    };
  };

in pkgs.writeText "dovecot-sieve-config" ''
  service managesieve-login {
    inet_listener sieve {
      name = sieve
      address = 127.0.0.1
      port = 4190
      ssl = yes
    }
  }

  service managesieve {
    # Blank line required syntactically
  }

  plugin {
    ${sieveSimpleConfig}

    # location of users' sieve directory and their "active" sieve script
    sieve = file:~/sieve;active=~/.dovecot.sieve

    # directory of global sieve scripts to run before and after processing ALL
    # incoming mail
    sieve_before = ${sieveScripts}/before
    sieve_after  = ${sieveScripts}/after

    # make sieve aware of user+tag@domain.tld aliases
    recipient_delimiter = +

    # maximum size of all user's sieve scripts
    sieve_quota_max_storage = 2M

    ## Spam and Ham learning ##

    # From elsewhere to Junk folder
    imapsieve_mailbox1_name = Junk
    imapsieve_mailbox1_causes = COPY
    imapsieve_mailbox1_before = file:${sieveScripts}/imap/report-spam.sieve

    # From Junk folder to elsewhere
    imapsieve_mailbox2_name = *
    imapsieve_mailbox2_from = Junk
    imapsieve_mailbox2_causes = COPY
    imapsieve_mailbox2_before = file:${sieveScripts}/imap/report-ham.sieve
  }
''
