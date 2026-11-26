# FNXNT — Fenix' Networking Tools

[![Build](https://github.com/dgcosenza/fnxnt-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/fnxnt-docker/actions/workflows/daily.yml)
[![Packaging](https://img.shields.io/badge/packaging-MIT-blue.svg)](LICENSE)
[![Upstream](https://img.shields.io/badge/upstream-Apache--2.0-lightgrey.svg)](THIRD-PARTY-NOTICES.md)
[![Image](https://img.shields.io/docker/pulls/dgcosenza/fnxnt.svg)](https://hub.docker.com/r/dgcosenza/fnxnt)
[![Signed](https://img.shields.io/badge/signed-cosign-blue.svg)](https://github.com/dgcosenza/fnxnt-docker)

Maintainer: Daniel G. Cosenza from FNX Labs

FNXNT is a production-hardened, multi-architecture network troubleshooting and diagnostics container. It provides full feature parity with upstream `nicolaka/netshoot` plus curated enhancements, a multi-stage build, a non-root user, and a rich interactive shell.

## Supported tags

- `latest` — latest build
- `<version>` — pinned FNXNT version (e.g. `1.0.15`)
- `<version>-<YYYYMMDD>` — immutable date-stamped build
- `sha-<short>` — git short SHA

Architectures: `linux/amd64`, `linux/arm64`.

## Quick start

```bash
# Interactive diagnostic session (root)
docker run -it --rm dgcosenza/fnxnt:latest

# Non-root user
docker run -it --rm --user netuser --workdir /home/netuser dgcosenza/fnxnt:latest

# Debug another container's network namespace
docker run -it --rm --net container:<target> dgcosenza/fnxnt:latest

# Debug host network
docker run -it --rm --net host --cap-add=NET_ADMIN --cap-add=NET_RAW dgcosenza/fnxnt:latest
```

## Configuration

The image is a debug toolbox; no environment variables or persistent volumes are required. Common usage patterns are documented in the upstream netshoot project.

- User: `netuser` (UID/GID 1000) available for non-root operation.
- Healthcheck: `ip link show lo` (capability-independent, passes under `--cap-drop=ALL`).
- Working directory: `/root` (default); `/home/netuser` for the non-root user.

## Security

- Base image: Alpine Linux 3.24.4, fully upgraded at build time.
- Trivy + Grype gate: zero fixable Critical/High (both architectures, on the SBOM).
- Non-root user `netuser` (UID 1000); capability-independent healthcheck.
- No secrets baked into layers.

## Build locally

```bash
docker build -t fnxnt:local .
docker buildx build --platform linux/amd64,linux/arm64 -t fnxnt:multi .
```

## Update policy

Rebuilt daily via GitHub Actions from the latest Alpine 3.24 packages and pinned upstream binaries. Tool versions are bumped in the Dockerfile; CI resolves and verifies them. See CHANGELOG.md for per-build entries.

## Design decisions

- Alpine Linux is used because it is the upstream-documented base for netshoot; Debian is not used here to preserve drop-in compatibility and tooling.
- MOTD and license documentation are stored as files under `scripts/` and `licenses/`-equivalent paths and copied in, rather than inlined.

## License

Packaging (Dockerfile, scripts, CI, docs) is MIT. Upstream netshoot components are Apache License 2.0 (nicolaka). Third-party tools retain their own licenses. See THIRD-PARTY-NOTICES.md and `/usr/share/licenses/fnxnt/` inside the image.

## Credits

Maintainer: Daniel G. Cosenza from FNX Labs. Upstream: https://github.com/nicolaka/netshoot.
