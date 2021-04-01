{ pkgs, ... }:
let
  whodir = "/run/whoroot";

  # A wrapper over w which replaces root with the username from the key
  # of the logged in rooter. The files in whodir are written by the
  # loginShellInit
  # The first regex removes the slash from the tty
  whoroot = pkgs.writeShellScriptBin "wroot" ''
    sedscript="s!pts/!pts!g;"
    for f in ${whodir}/*; do
      bf=$(basename $f)
      sedscript="''${sedscript}s!root +$bf!$(cat $f)\t$bf!g;"
    done
    ${pkgs.procps}/bin/w | ${pkgs.gnused}/bin/sed -E "$sedscript"
  '';
in {
  services.openssh = {
    enable = true;
    extraConfig = ''
      PermitUserEnvironment yes
    '';
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "environment=\"REMOTEUSER=m1cr0man\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnVLSh0OStxZTkXE6oGgwfFvsbvN6bFPlVfDYOwtnzn m1cr0man@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=m1cr0man\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPR+OTAIYr02f/WKQSXo7zYy9tkuAHYpy0ajqY6aJ7Nk m1cr0man@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=m1cr0man\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINV2JF6dDjXlmUgVlzk7y5VwXx4r5+1rd95e+lU4VayA m1cr0man@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=greenday\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJeCEU7Unc+4tGAMxyxy1bWxjoQ5oMN/igpqEnYZ9vDu greenday@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=mctastic\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjro8OS7cWf6xBcrs4erZqjN5JdztoGqpMXFQwzd9pV mctastic@azazel.redbrick.dcu.ie"
    "environment=\"REMOTEUSER=ylmcc\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkYUa7kSsf3sQWzx7L8M6wm4J5y14TA2pPM4hRCmlbE ylmcc@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=butlerx\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG/8Xf5/DtcOPjZKfag4ATBe5a3I1HvhYqi8fV7si4OU butlerx@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=d_fens\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhA5mm1sBzz6tcrUF2FzW6wrckW1IsQAyS8Bfu4yJRJ d_fens@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=fraz\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGybjW48+tQaykqDIuSeuH/3GLQRHZDa1toJOIB/FrD4 fraz@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=galvinio\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVc8zqnZkzsOHzfycpJ3QbB9SJ2FxmRRifYbBuuixk2 galvinio@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=mcmahon\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPzJW/r9XddCBa8Y1wLCt1FGNvGB3OD/fFzo19AE6/B mcmahon@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=mcmahon\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBimqBdbDEMad8eYwR5FDmBXNeSLQ3XjrGO0EEcISapq mcmahon@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=cianky\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3V7R686cBj5GbFRHUF7AnQvbPDfhW2CtZ7E5X4S3JS cianky@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=h_mzah\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFEh4xmAPcK7HvSRiFhHzyG6Tf1KjT4DH6KJv+Wrekk h_mzah@pygmalion.redbrick.dcu.ie"
  ];

  environment.loginShellInit = ''
    if [ -n "$REMOTEUSER" ]; then
      mkdir -p ${whodir}
      # The regex removes the slashes and /dev from the tty
      echo $REMOTEUSER > ${whodir}/$(tty | sed -E 's!(/dev)?/!!g')
    fi
  '';

  environment.systemPackages = [
    whoroot
  ];
}
