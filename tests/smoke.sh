#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-fnxnt:local}"

echo "==> smoke: image ${IMAGE}"

# Healthcheck command (capability-independent)
docker run --rm "${IMAGE}" ip link show lo >/dev/null
echo "healthcheck: ok"

# Non-root user
out=$(docker run --rm --user netuser --workdir /home/netuser "${IMAGE}" whoami)
[ "${out}" = "netuser" ] || { echo "non-root failed: ${out}"; exit 1; }
echo "non-root: ok"

# Tool presence
for t in curl dig nmap tcpdump kubectl grpcurl fortio trippy websocat; do
  docker run --rm "${IMAGE}" command -v "${t}" >/dev/null || { echo "missing tool ${t}"; exit 1; }
done
echo "tools: ok"

# MOTD renders
docker run --rm "${IMAGE}" fnxnt-motd >/dev/null
echo "motd: ok"

echo "==> smoke: PASS"
