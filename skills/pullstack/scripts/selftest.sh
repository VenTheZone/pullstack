#!/bin/sh
# Hostile-input tests for sandbox.sh and unpack.py. Prints one ok/FAIL line per check; exit code = number of failures.
# Files stay in ~/.cache/pullstack/work/selftest/<run>; the next pullstack run clears them.
here=$(dirname "$(realpath "$0")"); sb="$here/sandbox.sh"
d="$HOME/.cache/pullstack/work/selftest/$(date +%s)"; mkdir -p "$d/in"; fails=0
check() { if [ "$1" = 0 ]; then echo "ok   $2"; else echo "FAIL $2"; fails=$((fails + 1)); fi; }

python3 -I - "$d/in" <<'EOF'
import json, os, stat, sys, zipfile
d = sys.argv[1]
with zipfile.ZipFile(f"{d}/evil.zip", "w") as z:
    z.writestr("ok/readme.txt", "fine")
    z.writestr("../../../../tmp/pullstack-selftest-escape.txt", "escaped")
    link = zipfile.ZipInfo("link-to-home"); link.external_attr = (stat.S_IFLNK | 0o777) << 16
    z.writestr(link, os.path.expanduser("~"))
with zipfile.ZipFile(f"{d}/bomb.zip", "w", zipfile.ZIP_DEFLATED) as z, z.open("zeros.bin", "w", force_zip64=True) as f:
    mb = b"\0" * (1 << 20)
    for _ in range(3 << 10):  # 3 GiB of zeros, about 3 MB compressed
        f.write(mb)
os.makedirs(f"{d}/maps")
json.dump({"sources": ["../../../../tmp/pullstack-selftest-map.txt", "ok/fine.ts"], "sourcesContent": ["x", "y"]},
          open(f"{d}/maps/a.js.map", "w"))
EOF

sh "$sb" "$d/in/evil.zip" "$d/k" dmesg 2>/dev/null | grep -q gVisor; check $? "runs on the gVisor kernel"

sh "$sb" "$d/in/evil.zip" "$d/o1" unzip -q /in/evil.zip >/dev/null 2>&1
[ -f "$d/o1/ok/readme.txt" ] && [ ! -e /tmp/pullstack-selftest-escape.txt ]; check $? "zip path traversal stays inside the output"
[ -z "$(find "$d/o1" -type l)" ]; check $? "zip symlink member removed"

sh "$sb" "$d/in/bomb.zip" "$d/o2" unzip -q /in/bomb.zip >/dev/null 2>&1; rc=$?
[ "$rc" != 0 ] && [ -z "$(ls -A "$d/o2")" ]; check $? "zip bomb stopped, nothing copied out (exit $rc)"

sh "$sb" "$d/in/evil.zip" "$d/o3" python3 -c 'import urllib.request; urllib.request.urlopen("http://1.1.1.1", timeout=5)' >/dev/null 2>&1
[ $? != 0 ]; check $? "no network"

sh "$sb" "$d/in/evil.zip" "$d/o4" python3 -c 'b = bytearray(3 << 30)' >/dev/null 2>&1
[ $? != 0 ]; check $? "3 GB allocation refused"

sh "$sb" "$d/in/missing.zip" "$d/o5" true >/dev/null 2>&1; rc=$?
[ "$rc" = 2 ] && [ ! -e "$d/in/missing.zip" ]; check $? "missing artifact refused, not created"

sh "$sb" "$d/in/maps" "$d/o6" python3 /opt/pullstack/unpack.py maps /in/maps /work >/dev/null 2>&1
[ -f "$d/o6/a.js/ok/fine.ts" ] && [ ! -e /tmp/pullstack-selftest-map.txt ]; check $? "source-map path traversal stays inside the output"

exit "$fails"
