#!/usr/bin/env bash
# Smoke test for a built FNXNT candidate image.
# Verifies Docker reports the image HEALTHCHECK as healthy, that the toolkit is
# present, that the image also runs as the non-root user, and a negative test.
set -euo pipefail

IMAGE="${1:-fnxnt:local}"
NAME="fnxnt-smoke-$$"
cleanup() { docker rm -f "$NAME" >/dev/null 2>&1 || true; }
trap cleanup EXIT

echo "==> smoke: image ${IMAGE}"

docker run -d --name "$NAME" --entrypoint /bin/sleep "$IMAGE" 3600 >/dev/null

echo -n "healthcheck: "
for _ in $(seq 1 60); do
  state="$(docker inspect --format '{{.State.Health.Status}}' "$NAME" 2>/dev/null || echo missing)"
  case "$state" in
    healthy) echo "healthy"; break ;;
    unhealthy) echo "unhealthy"; docker logs "$NAME" || true; exit 1 ;;
    starting|missing) sleep 2 ;;
    *) echo "unexpected state: ${state}"; exit 1 ;;
  esac
done
[ "$(docker inspect --format '{{.State.Health.Status}}' "$NAME")" = "healthy" ] || {
  echo "container never reached healthy"; docker logs "$NAME" || true; exit 1;
}

# The healthcheck probe itself must work under a dropped capability set.
docker run --rm --cap-drop=ALL --entrypoint ip "$IMAGE" link show lo >/dev/null
echo "healthcheck probe without capabilities: ok"

# Tool parity: distro packages plus verified upstream release binaries.
docker exec "$NAME" sh -c '
  set -eu
  for t in curl wget dig drill nslookup host ss ip tcpdump tshark nmap \
           ngrep socat iftop iperf3 mtr jq yq kubectl grpcurl fortio \
           trippy websocat calicoctl ctop termshark kubecolor kubectx \
           kubens kubelogin hey swaks; do
    command -v "$t" >/dev/null || { echo "missing tool: $t" >&2; exit 1; }
  done
'
echo "tools: ok"

# Non-root operation is supported.
out="$(docker run --rm --user netuser --workdir /home/netuser "$IMAGE" whoami)"
[ "$out" = "netuser" ] || { echo "non-root failed: ${out}"; exit 1; }
echo "non-root: ok"

# MOTD renders without a terminal attached.
docker run --rm "$IMAGE" fnxnt-motd >/dev/null
echo "motd: ok"

# Negative test: an unknown tool must not be found.
if docker exec "$NAME" command -v fnxnt-no-such-tool >/dev/null 2>&1; then
  echo "negative test failed"; exit 1
fi
echo "negative test: ok"

echo "==> smoke: PASS"
