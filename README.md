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

## Deploying Apache/httpd

`users.nix` needs to be generated before deploying Apache. Use this command:

```bash
cd services/httpd
ldapsearch -b o=redbrick -h ldap.internal -xLLL objectClass=posixAccount uid homeDirectory gidNumber | python3 ldap2nix.py /storage/webtree/ > users.nix
```
