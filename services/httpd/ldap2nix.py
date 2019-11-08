#!/usr/bin/env python3
# stdin: ldif formatted user data with uid, homeDirectory and gidNumber fields
# stdout: Nix formatted list of user attrsets
import sys

def user2nix(uid: str, home: str, gid: str) -> str:
    return '\n'.join([
        '  {',
        f'    uid = "{uid}";',
        f'    home = "{home}";',
        f'    gid = {gid};',
        '  }'
    ])


def main():
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
            gid = val

        if uid and home and gid:
            print(user2nix(uid=uid, home=home, gid=gid))
            num_users += 1
            uid = home = gid = ''

    print(']')

    print(f'Generated nix config for {str(num_users)} users', file=sys.stderr)


if __name__ == '__main__':
    main()
