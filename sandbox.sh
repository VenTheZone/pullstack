#!/bin/sh
# Run one unpacking command on an untrusted artifact inside a throwaway gVisor container (its own kernel, not the host's):
# no network, no capabilities, read-only image, artifact mounted read-only at /in/<name>, 2 GB RAM including a 1 GB work
# tmpfs (zip bombs stop there), 2 CPUs at low priority so other services win under load, 10 min cap.
# On success the result is copied to <outdir> and every symlink in it is deleted. On failure <outdir> stays empty.
#   sandbox.sh <artifact> <outdir> <command...>     e.g.  sandbox.sh app.apk ~/.cache/pullstack/work/x/apk unzip -q /in/app.apk
set -eu
[ $# -ge 3 ] || { sed -n '2,5p' "$0"; exit 2; }
[ -e "$1" ] || { echo "sandbox.sh: no such artifact: $1" >&2; exit 2; }   # docker -v would create it as an empty dir
art=$(realpath "$1"); out=$2; shift 2
mkdir -p "$out"; out=$(realpath "$out")
dir=$(dirname "$(realpath "$0")"); img=pullstack-sandbox:1
docker info --format '{{json .Runtimes}}' | grep -q '"runsc"' || { echo 'sandbox.sh: Docker has no runsc (gVisor) runtime; install it: https://gvisor.dev/docs/user_guide/install' >&2; exit 3; }
docker image inspect "$img" >/dev/null 2>&1 || docker build -q -t "$img" "$dir" >/dev/null
rc=0
docker run --rm --runtime runsc --network none --read-only --cap-drop ALL --security-opt no-new-privileges \
  --pids-limit 256 --memory 2g --memory-swap 2g --cpus 2 --cpu-shares 256 --user "$(id -u):$(id -g)" \
  --tmpfs /tmp:size=256m --tmpfs "/work:size=1g,uid=$(id -u),gid=$(id -g)" \
  -v "$art:/in/$(basename "$art"):ro" -v "$out:/out" -w /work \
  "$img" sh -c 'timeout 600 "$@" && cp -a /work/. /out/' sh "$@" || rc=$?   # failed or cut off (bomb, timeout): copy nothing
find "$out" -type l -delete
exit "$rc"
