#!/usr/bin/env bash
set -euo pipefail
ldapsearch -b o=redbrick -h ldap.internal -xLLL -S uid objectClass=posixAccount uid gidNumber homeDirectory | python3 ldap2nix.py /storage/webtree > usersnew.nix
mv usersnew.nix users.nix
