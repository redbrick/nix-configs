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

  services.fail2ban = {
    enable = true;
    ignoreIP = [
      "10.0.0.0/8"
      "192.168.0.0/16"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "environment=\"REMOTEUSER=greenday\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJeCEU7Unc+4tGAMxyxy1bWxjoQ5oMN/igpqEnYZ9vDu greenday@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=mctastic\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjro8OS7cWf6xBcrs4erZqjN5JdztoGqpMXFQwzd9pV mctastic@azazel.redbrick.dcu.ie"
    "environment=\"REMOTEUSER=butlerx\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG/8Xf5/DtcOPjZKfag4ATBe5a3I1HvhYqi8fV7si4OU butlerx@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=d_fens\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhA5mm1sBzz6tcrUF2FzW6wrckW1IsQAyS8Bfu4yJRJ d_fens@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=fraz\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGybjW48+tQaykqDIuSeuH/3GLQRHZDa1toJOIB/FrD4 fraz@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=galvinio\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVc8zqnZkzsOHzfycpJ3QbB9SJ2FxmRRifYbBuuixk2 galvinio@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=mcmahon\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPzJW/r9XddCBa8Y1wLCt1FGNvGB3OD/fFzo19AE6/B mcmahon@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=mcmahon\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBimqBdbDEMad8eYwR5FDmBXNeSLQ3XjrGO0EEcISapq mcmahon@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=cianky\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3V7R686cBj5GbFRHUF7AnQvbPDfhW2CtZ7E5X4S3JS cianky@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=distro\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDunUsPaNZ/+e2J8S0QAFqfqZSfTWboMfmf1R6iCnLeK distro@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=h_mzah\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFEh4xmAPcK7HvSRiFhHzyG6Tf1KjT4DH6KJv+Wrekk h_mzah@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=skins\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOM3F35Ac7SsoVbeaytbvtjtO00ROfWsg5PMhXswZQVd skins@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=pints\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3yU3wHKPZIaNYFL9HuV6RPdQdmg13VDRXE3lQmAoW5w8CZdFYP2z123Fi8lV4WjCdCVVm7L8q14BZrPTkqZVzE5VXsJ5N8OMgKu8NrGIS2ur4ICmA9cetbNMk/Ie9UI5pD1HwnZ/OupoO0ShBRgNc7JM4K+xTAnfAasyGdlSIdWDLJIAUqDE3EhZn7iivudawM86qNq0n+rG5MdMRbuiGCsOY5bXaYSGZ3dGUu2nRjQWmBaIc3Xlz+C8WfKvZEurT+egf16ghGomKO5dxhGB4tmuceJqLoXR0HrHxaQtJXgEV7E5PPzutOIPjVlB/IkCrYQBgyybR46BtMGlRLtag/+w4nNhZ8VUyyh63DH2rp2vVIV0rfsNnuSh3eo25uqaStuOVuV2cia1MwOkA6/tvqQCFrCqQMTgHWL/RqLyH0KLNb3QdKNjaNCvjo5aFSuzUlFRKW3NWdM5KQ0uU+XrRThKQGy96+FClNF3/QQtyyci3a0/39hzVSw9rSpC+Ve0= pints@DESKTOP-J693KB9"
    "environment=\"REMOTEUSER=newt\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMv9WP/C7OmhOS90WTWa7pHmHBaEkyzsWGABnE+r+97t newt@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=cawnj\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKleIRdoz3RX2wN9BgKfbBnBXa4vN8+fyguVx2ANtV8t cawnj@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=mag1c\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFb1QaDQG0ZmyNgOIGNFsl7B3aGFjcBtrK3189bIPCY9 mag1c@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=wizzdom\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPb9B8bJohwDXxNTkdt4qnCTKJeOnRe2zP+r/7A18FG wizzdom@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=cathalog\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJITEcseJCDdmwPAKFKI4sLN/EdPUSyn4QPyPy/cNMBk cathalog@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=ymacomp\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsl1p/5FASxldsNV2fMGx05R88wR0lKiVjTBARc2Ol1 ymacomp@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=hypnoant\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOmuvF9UaEM6X/qtphksGaBnMablsq8o9BG3rYdbILdx hypnoant@pygmalion.redbrick.dcu.ie"
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
