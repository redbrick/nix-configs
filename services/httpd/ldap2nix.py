#!/usr/bin/env python3
# Redbrick - m1cr0man 2019
# stdin: ldif formatted user data with uid, homeDirectory and gidNumber fields
# stdout: Nix formatted list of user attrsets
# Make sure to run on a host with LDAP set up or everyone will have gid nobody
import functools
import os.path
import subprocess
import sys

def user2nix(uid: str, home: str, gid: str) -> str:
    return '\n'.join([
        '  {',
        f'    uid = "{uid}";',
        f'    home = "{home}";',
        f'    gid = "{gid}";',
        '  }'
    ])


@functools.lru_cache(maxsize=128)
def get_gid_from_number(gid: str) -> str:
    group_query = subprocess.run(f'getent group {gid}', shell=True, encoding='utf8', stdout=subprocess.PIPE)
    if group_query.returncode > 0:
        return 'nobody'
    return group_query.stdout.split(':')[0]


def main(webtree: str):
    num_users = 0

    print('[')

    uid = home = gid = ''
    for line in sys.stdin:
        split_line = line.strip().split(': ')
        if len(split_line) < 2:
            continue
        key, val = split_line
        if key == 'uid':
            uid = val
        elif key == 'homeDirectory':
            home = val
        elif key == 'gidNumber':
            gid = get_gid_from_number(val)

        if uid and home and gid:
            if os.path.exists(f'{webtree}/{uid[0]}/{uid}') or '/var/lib' in home:
                print(user2nix(uid=uid, home=home, gid=gid))
                num_users += 1
            else:
                print(f'Skipping {uid}: missing webtree', file=sys.stderr)
            uid = home = gid = ''

    print(']')

    print(f'Generated nix config for {str(num_users)} users', file=sys.stderr)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f'Usage: {sys.argv[0]} webtree_path')
        sys.exit(1)
    main(sys.argv[1])
