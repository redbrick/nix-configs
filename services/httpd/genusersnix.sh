#!/usr/bin/env bash
set -euo pipefail
ldapsearch -b o=redbrick -h ldap.internal -xLLL -S uid objectClass=posixAccount uid gidNumber homeDirectory | python3 ldap2nix.py /storage/webtree > usersnew.nix
test ! -e usersold.nix || rm usersold.nix
test ! -e users.nix || mv users.nix usersold.nix
mv usersnew.nix users.nix
