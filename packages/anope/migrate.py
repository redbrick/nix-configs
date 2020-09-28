#!/usr/bin/env python3
"""
Migrate users from Anope 1.6 to Anope 2.0 (SQLite).
"""

import hashlib
import sqlite3
import struct
from pprint import pprint
from typing import Callable, Tuple

NS_VERBOTEN = 0x0002
NS_TEMPORARY = 0xFF00

NI_SERVICES_ROOT = 0x00008000

FILE = "nick.db"
NEW_FILE = "anope.db"
PREFIX = "anope_db_"


def unpacker(filename: str) -> Tuple[Callable, Callable]:
    buf = open(filename, "rb")
    offset = 0

    def unpack(fmt):
        res = struct.unpack_from(fmt, buf, offset)
        offset += struct.calcsize(format)
        return res

    def unpack_string(size=None):
        if size is None:
            size = unpack(">h")
            if size == 0:
                return None
        else:
            size = 32
        return unpack("%ds" % size)[0][:-1]

    return unpack, unpack_string

    # based on nickserv.c/load_ns_dbase
    p = unpacker(file)
    (version,) = p.unpack(">i")
    print("Version:", version)

    # read nick cores
    nick_cores = {}
    for i in range(1024):
        if p.unpack("b")[0] == 1:
            nc = {}
            nc["display"] = p.unpack_string()
            if version < 14:
                nc["pass"] = p.unpack_string()
            else:
                nc["pass"] = p.unpack_string(32)
            nc["email"] = p.unpack_string()
            nc["greet"] = p.unpack_string()
            nc["icq"] = p.unpack(">i")[0]
            nc["url"] = p.unpack_string()
            nc["flags"] = p.unpack(">i")[0]
            nc["language"] = p.unpack(">h")[0]

            nc["accesscount"] = p.unpack(">h")[0]
            nc["access"] = []
            for access in range(nc["accesscount"]):
                nc["access"].append(p.unpack_string())

            nc["memos.memocount"] = p.unpack(">h")[0]
            nc["memos.memomax"] = p.unpack(">h")[0]
            nc["memos.memos"] = []
            for memo_i in range(nc["memos.memocount"]):
                memo = {}
                memo["number"] = p.unpack(">i")[0]
                memo["flags"] = p.unpack(">h")[0]
                memo["time"] = p.unpack(">i")[0]
                memo["sender"] = p.unpack_string()
                memo["text"] = p.unpack_string()

            nc["channelcount"] = p.unpack(">h")[0]
            p.unpack(">h")[0]
            if version < 13:
                p.unpack(">h")[0]
                p.unpack(">i")[0]
                p.unpack(">h")[0]
                p.unpack_string()

            nc["aliases"] = []

            nick_cores[nc["display"]] = nc

    # read nick cores
    nick_aliases = {}
    for i in range(1024):
        if p.unpack("b")[0] == 1:
            na = {}
            na["nick"] = p.unpack_string()

            na["last_usermask"] = p.unpack_string()
            na["last_realname"] = p.unpack_string()
            na["last_quit"] = p.unpack_string()

            na["time_registered"] = p.unpack(">i")[0]
            na["last_seen"] = p.unpack(">i")[0]
            na["status"] = p.unpack(">h")[0] & ~NS_TEMPORARY

            core_name = p.unpack_string()
            na["nc"] = nick_cores[core_name]
            nick_cores[core_name]["aliases"].append(na)

            if not na["status"] & NS_VERBOTEN:
                if not na["last_usermask"]:
                    na["last_usermask"] = ""
                if not na["last_realname"]:
                    na["last_realname"] = ""

            na["nc"]["flags"] &= ~NI_SERVICES_ROOT

            nick_aliases[na["nick"]] = na

    # pprint(nick_cores)
    # pprint(nick_aliases)


# write passwords md5-encoded to SQLite database
conn = sqlite3.connect(NEW_FILE)
c = conn.cursor()

c.execute(
    "SELECT name, sql FROM `sqlite_master` WHERE `type`='trigger' AND `tbl_name`='{prefix}NickCore'".format(
        prefix=PREFIX
    )
)
trigger = c.fetchone()
c.execute("DROP TRIGGER {trigger[0]}".format(trigger=trigger))

try:
    for nc in nick_cores.values():
        display = nc["display"].decode()
        password = nc["pass"]
        new_password = "md5:" + hashlib.md5(password).hexdigest()
        print("Handling nick core", display)
        c.execute(
            "SELECT `display`, `email` FROM {prefix}NickCore WHERE `display`=?".format(
                prefix=PREFIX
            ),
            (display,),
        )
        result = c.fetchone()
        if result is None:
            print("  NOT FOUND")
        else:
            print("  found: display=%s, mail=%s" % result)
            print("  encrypted password:", new_password)
            c.execute(
                "UPDATE anope_db_NickCore SET `pass`=? WHERE `display`=?",
                (new_password, display),
            )

finally:
    c.execute(trigger[1])
