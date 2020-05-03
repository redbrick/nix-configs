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
    "environment=\"REMOTEUSER=m1cr0man\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYKnYP4Mmyk4wQE7J6Tyr27XToKtxAhXBZr5HkEXiFq m1cr0man@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=greenday\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvabMrrJILDua2sedVqBStb6YKBHpgCO5HOM98l7uwf greenday@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=mctastic\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjro8OS7cWf6xBcrs4erZqjN5JdztoGqpMXFQwzd9pV mctastic@azazel.redbrick.dcu.ie"
    "environment=\"REMOTEUSER=ylmcc\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLSLIF2IOo/OzbmbMGp4kt6VP2z8zNCuuVNyuxyBU0A8cOeUhkAbVibVmFqPlcHDJ4+zhkNN0GDnEJEUAmBNi+yc9EJG7StxdguEAKPlA9gQ/Z73cMrfMHtTPOHj/uCKUqi9vzb3tlOltJmuS3SwF0B5dk58j/cwr3nEEzikMmQIykxI+F+rxMnxaQXtNBGz3ednAaJ4Lvv9JSxWcExEtU0lM0X1MgZgkYFr48uQwsDUE+j23+wifMrOA+zhC0uRcuIapnxsyoW/wDOYrQZFlw6acrVX+zNtxcCQoqIX4oAobCXn7tYz9peKrV8TmJwQOspsmyY75xIAbyz0AiD3oh ylmcc@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=butlerx\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG/8Xf5/DtcOPjZKfag4ATBe5a3I1HvhYqi8fV7si4OU butlerx@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=d_fens\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhA5mm1sBzz6tcrUF2FzW6wrckW1IsQAyS8Bfu4yJRJ d_fens@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=fraz\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGybjW48+tQaykqDIuSeuH/3GLQRHZDa1toJOIB/FrD4 fraz@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=galvinio\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVc8zqnZkzsOHzfycpJ3QbB9SJ2FxmRRifYbBuuixk2 galvinio@redbrick.dcu.ie"
    "environment=\"REMOTEUSER=mcmahon\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPzJW/r9XddCBa8Y1wLCt1FGNvGB3OD/fFzo19AE6/B mcmahon@redbrick.dcu.ie"
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
