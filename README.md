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

Then generate the preliminary certs for every domain so that httpd can start:
```bash
# List all acme-selfsigned-* services and put them in a txt file. Do this with `systemctl status acme-selfsigned-<tab>`
cat selfsigned-svcs.txt | xargs systemctl start
```

Now apache will start. Generate the real certs for each domain, one at a time as to not get rate limited

```bash
cd /var/lib/acme
for cert in *; do journalctl -fu acme-$cert.service & systemctl start acme-$cert.service && kill $!; done
systemctl reload httpd
```
