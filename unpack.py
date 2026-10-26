#!/usr/bin/env python3
"""Static unpacking for pullstack's no-repo route. Reads files only; never runs anything from them.

  unpack.py asar <app.asar> <outdir>   extract an Electron archive (stdlib, no npm)
  unpack.py maps <dir> <outdir>        write the original sources embedded in *.map files (sourcesContent)

Input is untrusted: every output path is checked to stay inside <outdir>.
"""
import json, os, posixpath, struct, sys


def safe_join(root, *rels):
    # normpath of "/"+rel can't climb above "/", so "../../etc/x" becomes "etc/x"; realpath then catches symlinks.
    rels = [posixpath.normpath("/" + r.replace("\\", "/")).lstrip("/") for r in rels]
    path = os.path.realpath(os.path.join(root, *rels))
    if not path.startswith(os.path.realpath(root) + os.sep):
        raise ValueError(f"refusing path outside output: {'/'.join(rels)!r}")
    return path


def asar(src, out):
    with open(src, "rb") as f:
        _, header_size = struct.unpack("<II", f.read(8))
        _, json_len = struct.unpack("<II", f.read(8))
        header = json.loads(f.read(json_len))
        base = 8 + header_size
        n = 0

        def walk(node, rel):
            nonlocal n
            for name, e in node.get("files", {}).items():
                child = f"{rel}/{name}" if rel else name
                if "files" in e:
                    walk(e, child)
                elif "offset" in e and not e.get("unpacked"):  # unpacked files sit in <app>.asar.unpacked/
                    dest = safe_join(out, child)
                    os.makedirs(os.path.dirname(dest), exist_ok=True)
                    f.seek(base + int(e["offset"]))
                    with open(dest, "wb") as o:
                        o.write(f.read(e["size"]))
                    n += 1

        walk(header, "")
    print(f"{n} files -> {out}")


def maps(src, out):
    n = skipped = 0
    for dirpath, _, names in os.walk(src):
        for name in names:
            if not name.endswith(".map"):
                continue
            try:
                m = json.load(open(os.path.join(dirpath, name), encoding="utf-8"))
            except (ValueError, UnicodeDecodeError):
                continue
            for path, body in zip(m.get("sources", []), m.get("sourcesContent") or []):
                if body is None:
                    continue
                path = path.split("://", 1)[-1].split("?", 1)[0]  # webpack://app/src/x.ts → app/src/x.ts
                try:
                    dest = safe_join(out, name[:-4], path)  # one folder per map: sources from different maps never collide
                    os.makedirs(os.path.dirname(dest), exist_ok=True)
                    with open(dest, "w", encoding="utf-8") as o:
                        o.write(body)
                    n += 1
                except (OSError, ValueError):  # path clash between sources, or a path refused by safe_join
                    skipped += 1
    print(f"{n} sources -> {out}" + (f", {skipped} skipped (path clash or refused)" if skipped else ""))


if __name__ == "__main__":
    if len(sys.argv) != 4 or sys.argv[1] not in ("asar", "maps"):
        sys.exit(__doc__)
    {"asar": asar, "maps": maps}[sys.argv[1]](sys.argv[2], sys.argv[3])
