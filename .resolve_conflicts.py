#!/usr/bin/env python3
"""Conflict resolver helper.

Usage:
  resolve_conflicts.py ours <file>            # take HEAD side for every hunk
  resolve_conflicts.py theirs <file>          # take upstream side for every hunk
  resolve_conflicts.py pick <file> <spec>     # per-hunk pick, spec like "o,o,t,o" (1-based order)
  resolve_conflicts.py list <file>            # print hunks with index + both sides
"""
import sys

START = "<<<<<<<"
MID = "======="
END = ">>>>>>>"


def parse(path):
    with open(path, "r") as f:
        lines = f.readlines()
    segments = []  # ('text', str) or ('hunk', ours_lines, theirs_lines)
    i = 0
    buf = []
    while i < len(lines):
        line = lines[i]
        if line.startswith(START):
            if buf:
                segments.append(("text", buf))
                buf = []
            ours = []
            i += 1
            while not lines[i].startswith(MID):
                ours.append(lines[i])
                i += 1
            i += 1  # skip MID
            theirs = []
            while not lines[i].startswith(END):
                theirs.append(lines[i])
                i += 1
            i += 1  # skip END
            segments.append(("hunk", ours, theirs))
        else:
            buf.append(line)
            i += 1
    if buf:
        segments.append(("text", buf))
    return segments


def main():
    mode = sys.argv[1]
    path = sys.argv[2]
    segs = parse(path)
    hunks = [s for s in segs if s[0] == "hunk"]
    if mode == "list":
        for idx, (_, ours, theirs) in enumerate(hunks, 1):
            print(f"=========== HUNK {idx} ===========")
            print("----- OURS -----")
            sys.stdout.write("".join(ours))
            print("----- THEIRS -----")
            sys.stdout.write("".join(theirs))
        print(f"TOTAL HUNKS: {len(hunks)}")
        return

    if mode == "pick":
        spec = sys.argv[3].split(",")
        if len(spec) != len(hunks):
            print(f"ERROR: spec has {len(spec)} picks but file has {len(hunks)} hunks")
            sys.exit(1)
    out = []
    hi = 0
    for s in segs:
        if s[0] == "text":
            out.extend(s[1])
        else:
            _, ours, theirs = s
            if mode == "ours":
                out.extend(ours)
            elif mode == "theirs":
                out.extend(theirs)
            elif mode == "pick":
                choice = spec[hi].strip().lower()
                out.extend(ours if choice == "o" else theirs)
            hi += 1
    with open(path, "w") as f:
        f.writelines(out)
    print(f"Resolved {len(hunks)} hunks in {path} (mode={mode})")


if __name__ == "__main__":
    main()
