#!/usr/bin/env python3
# Python 3.6+
# Converts exim aliases text file to Nix
# Usage: cat exim_aliases.txt | ./exim2nix.py > aliases.nix
import sys

print('{')
for l in sys.stdin:
    if '#' not in l and ':' in l:
        try:
            alias, to = l.strip().split(':')
        except:
            print("Broken line", l.strip())
            continue
        alias = alias.strip()
        to = to.strip().replace('"', r'\"')
        print(f"  \"{alias}\" = \"{to}\";")
    else:
        print(l.strip())
print('}')
