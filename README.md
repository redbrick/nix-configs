# NixOS Configurations

Used to deploy redbrick 2.0

## Installation

```bash
cd /etc/nixos
tar -cjf ~/nixos_backup.tar.bz2 *
rm *
git clone $THIS_REPO .
ln -s hosts/$(hostname)/configuration.nix .
nixos-rebuild switch
```
