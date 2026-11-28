# FNXNT — Fenix' Networking Tools

[![Daily CI](https://github.com/dgcosenza/fnxnt-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/fnxnt-docker/actions/workflows/daily.yml)
[![OpenSSF Scorecard Workflow](https://github.com/dgcosenza/fnxnt-docker/actions/workflows/scorecard.yml/badge.svg)](https://github.com/dgcosenza/fnxnt-docker/actions/workflows/scorecard.yml)
[![Gitleaks Secret Scan](https://github.com/dgcosenza/fnxnt-docker/actions/workflows/gitleaks.yml/badge.svg)](https://github.com/dgcosenza/fnxnt-docker/actions/workflows/gitleaks.yml)
[![Public Content Check](https://github.com/dgcosenza/fnxnt-docker/actions/workflows/public-check.yml/badge.svg)](https://github.com/dgcosenza/fnxnt-docker/actions/workflows/public-check.yml)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/dgcosenza/fnxnt-docker/badge)](https://scorecard.dev/viewer/?uri=github.com/dgcosenza/fnxnt-docker)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/17159/badge)](https://www.bestpractices.dev/projects/17159)

[![Trivy + Grype: 0 Fixable CVEs](https://img.shields.io/badge/Trivy%20%2B%20Grype-0%20fixable%20CVEs-brightgreen?logo=trivy&logoColor=white)](https://github.com/dgcosenza/fnxnt-docker/security/code-scanning)
[![Signed: Cosign OIDC](https://img.shields.io/badge/signed-Cosign%20OIDC-blueviolet)](https://github.com/dgcosenza/fnxnt-docker#security)
[![SLSA Build L3](https://img.shields.io/badge/SLSA-Build%20L3-brightgreen)](https://github.com/dgcosenza/fnxnt-docker/attestations)
[![SBOM: SPDX + CycloneDX](https://img.shields.io/badge/SBOM-SPDX%20%2B%20CycloneDX-0A7BBB?logo=spdx&logoColor=white)](https://github.com/dgcosenza/fnxnt-docker/releases/latest)
[![Base OS](https://img.shields.io/badge/base-Debian%2013%20(trixie--slim)-A81D33?logo=debian&logoColor=white)](https://github.com/dgcosenza/fnxnt-docker/blob/main/Dockerfile)
[![Architectures](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-007ec6?logo=linux&logoColor=white)](https://github.com/dgcosenza/fnxnt-docker#supported-tags)
[![Healthcheck: CI Verified](https://img.shields.io/badge/healthcheck-CI%20verified-brightgreen?logo=docker&logoColor=white)](https://github.com/dgcosenza/fnxnt-docker#healthcheck)
[![Renovate Enabled](https://img.shields.io/badge/renovate-enabled-1A1F6C?logo=renovate&logoColor=white)](https://github.com/dgcosenza/fnxnt-docker/blob/main/renovate.json)
[![Dependabot Enabled](https://img.shields.io/badge/dependabot-enabled-025E8C?logo=dependabot&logoColor=white)](https://github.com/dgcosenza/fnxnt-docker/blob/main/.github/dependabot.yml)
[![Daily Rebuilds](https://img.shields.io/badge/rebuilds-daily-2088FF?logo=githubactions&logoColor=white)](https://github.com/dgcosenza/fnxnt-docker/actions/workflows/daily.yml)

[![Latest Release](https://img.shields.io/github/v/release/dgcosenza/fnxnt-docker?label=version&logo=github)](https://github.com/dgcosenza/fnxnt-docker/releases/latest)
[![Release Date](https://img.shields.io/github/release-date/dgcosenza/fnxnt-docker?label=released&logo=github)](https://github.com/dgcosenza/fnxnt-docker/releases/latest)
[![Last Commit](https://img.shields.io/github/last-commit/dgcosenza/fnxnt-docker?logo=github)](https://github.com/dgcosenza/fnxnt-docker/commits/main)
[![Docker Pulls](https://img.shields.io/docker/pulls/dgcosenza/fnxnt?logo=docker&logoColor=white)](https://hub.docker.com/r/dgcosenza/fnxnt)
[![Docker Image Size](https://img.shields.io/docker/image-size/dgcosenza/fnxnt/latest?logo=docker&logoColor=white)](https://hub.docker.com/r/dgcosenza/fnxnt)
[![Registries: Docker Hub + GHCR](https://img.shields.io/badge/registries-Docker%20Hub%20%2B%20GHCR-2496ED?logo=docker&logoColor=white)](https://github.com/dgcosenza/fnxnt-docker/pkgs/container/fnxnt)
[![Packaging License: MIT](https://img.shields.io/badge/packaging-MIT-blue?logo=opensourceinitiative&logoColor=white)](https://github.com/dgcosenza/fnxnt-docker/blob/main/LICENSE)
[![Upstream License](https://img.shields.io/badge/upstream-Apache--2.0-green?logo=opensourceinitiative&logoColor=white)](https://github.com/dgcosenza/fnxnt-docker/blob/main/THIRD-PARTY-NOTICES.md)
[![GitHub Issues](https://img.shields.io/github/issues/dgcosenza/fnxnt-docker?logo=github)](https://github.com/dgcosenza/fnxnt-docker/issues)
[![FNX Labs Catalog](https://img.shields.io/badge/catalog-FNX%20Labs-0b1020?logo=githubpages&logoColor=white)](https://dgcosenza.github.io/)

Maintainer: Daniel G. Cosenza from FNX Labs

FNXNT is a network troubleshooting and diagnostics container built on the current Debian stable slim release. It provides netshoot-equivalent tooling, curated modern additions, a non-root user, a rich interactive shell, and a real container healthcheck. The image is rebuilt, scanned, signed, and published daily.

## Current versions

<!-- versions:start -->
| Component | Resolved Version |
| --- | --- |
| FNXNT | `1.0.16` |
| Base OS | `Debian 13.8 (stable-slim)` |
| Architectures | `linux/amd64, linux/arm64` |
| Uncompressed size (per arch) | `amd64: 349.8 MB, arm64: 1082.3 MB` |
| Last verified build (UTC) | `2026-11-28` |
| Published multi-arch digest | `dgcosenza/fnxnt@sha256:eda233aff03eb9bee326d133253f26b53a62972a8654b6581c263cd84d71cf4f` |
| GHCR mirror | `ghcr.io/dgcosenza/fnxnt@sha256:eda233aff03eb9bee326d133253f26b53a62972a8654b6581c263cd84d71cf4f` |
| Supply chain | Cosign OIDC signed + SPDX & CycloneDX SBOM attestations + SLSA Build L3 provenance |
| Security gate (Trivy + Grype on SBOM) | **0 fixable findings of any severity** (82 upstream-unfixed) |

**Recent upstream changes:**
- **FNXNT:** `1.0.16` -> `1.0.16`
- **Version changed:** `no`
- **Base image:** `debian:13.8-slim` pinned at `sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0`
- `bcicen/ctop`: pinned `n/a`; latest `v0.7.7`
- `projectcalico/calico`: pinned `n/a`; latest `v3.33.1`
<!-- versions:end -->

## Supported tags

- `latest` — latest successful build
- `<version>` — pinned FNXNT version, e.g. `1.0.16`
- `<version>-<YYYYMMDD>` — immutable date-stamped build
- `sha-<short>` — git short SHA

Available for `linux/amd64` and `linux/arm64` from `dgcosenza/fnxnt` and `ghcr.io/dgcosenza/fnxnt`. Both registries carry the identical signed multi-arch digest.

## Quick start

```bash
# Interactive diagnostic session
docker run -it --rm dgcosenza/fnxnt:latest

# Non-root shell
docker run -it --rm --user netuser --workdir /home/netuser dgcosenza/fnxnt:latest

# Debug another container's network namespace
docker run -it --rm --net container:<target> dgcosenza/fnxnt:latest

# Host networking with the capabilities raw-socket tools need
docker run -it --rm --net host --cap-add=NET_ADMIN --cap-add=NET_RAW dgcosenza/fnxnt:latest
```

## Compose example

```yaml
services:
  debug:
    image: dgcosenza/fnxnt:latest
    network_mode: "service:app"
    cap_drop: [ALL]
    cap_add: [NET_RAW, NET_ADMIN]
    security_opt: ["no-new-privileges:true"]
    read_only: true
    tmpfs: ["/tmp"]
    command: tcpdump -i eth0 -nn -w /tmp/traffic.pcap
  app:
    image: nginx:stable
    ports: ["127.0.0.1:8080:80"]
```

A fuller example is in `docker-compose.example.yml`.

## Configuration

FNXNT is a debug toolbox: no mandatory environment variables, volumes, or exposed ports.

| Setting | Value |
| --- | --- |
| Base image | `debian:13.8-slim` (pinned by digest, refreshed daily) |
| User | root by default (matching upstream netshoot); `netuser` UID/GID 1000 for non-root use |
| Working directory | `/root`, or `/home/netuser` for the non-root user |
| Shell | zsh with Oh My Zsh (`/bin/zsh`); bash is also available |
| Variables | `FNXNT_VERSION` (informational) and standard locale variables |
| Volumes | none required; mount a directory only when capturing output |
| Ports | none listened on; outbound diagnostics only |

## Healthcheck

`HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD ["ip", "link", "show", "lo"]`

The probe queries the loopback interface through netlink, so it needs no `NET_RAW` capability and stays healthy under `cap_drop: ALL`. CI starts the container on both architectures, waits until Docker reports `health=healthy`, and runs the smoke suite before publishing. Do not disable this probe in a compose override.

## Upgrade / migration

Replace the previous image reference with `dgcosenza/fnxnt@sha256:<digest>` (the digest published in the GitHub Release for each build). Environment variables, shell configuration, tool paths, and the `netuser` UID/GID are unchanged; no data migration is required. The base operating system moved from Alpine to Debian: compiled tools are supplied as static upstream binaries and distro packages carry equivalent functionality. Tools without an equivalent Debian package continue to be copied from the verified release bundle.

## Security

- Both stages use current Debian stable slim (the Go builder is the official `golang:1.27.4-trixie` image pinned by digest); packages are fully upgraded at build time and apt lists are removed.
- Trivy hard gate: `UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL`, `--ignore-unfixed`, exit code 1. Grype hard gate on the SPDX SBOM: `--only-fixed --fail-on negligible`. Both fail on **any fixable finding of any severity**, on each architecture. No gate is weakened for a release.
- All Go tools are compiled from official pinned release sources with the patched Go 1.27.4 toolchain and with every Go module that has a published security fix advanced to a fixed version. Rust static binaries and the swaks script are pinned and SHA-256 verified.
- Native `ubuntu-24.04-arm` runner builds and smoke-tests the arm64 image; no emulation gap.
- Keyless Cosign signatures and signed SPDX/CycloneDX SBOM attestations on both registries; SLSA Build L3 provenance; Renovate, Dependabot, Hadolint, Gitleaks, public-content check, Scorecard, Dive, and Trivy SARIF upload are part of CI.
- No secrets are baked into layers.

Verify a published digest:

```bash
cosign verify --certificate-identity-regexp='^https://github\.com/dgcosenza/fnxnt-docker/\.github/workflows/daily\.yml@refs/heads/main$' \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com \
  ghcr.io/dgcosenza/fnxnt@sha256:<digest>
```

Unfixed findings, if any, are listed with justification in the latest GitHub Release notes. Current gate status: see the build badge and the release artifacts.

## Build locally

```bash
docker build --build-arg FNXNT_VERSION=1.0.16 -t fnxnt:local .
docker buildx build --platform linux/amd64,linux/arm64 -t fnxnt:multi .
./tests/smoke.sh fnxnt:local
```

## Update policy

Every day CI checks the GitHub releases API (authenticated) for newer tool versions, resolves the current Debian stable slim digest, rebuilds with `--no-cache`, verifies checksums, runs the health/smoke tests on both architectures, scans with Trivy and Grype, signs and publishes date-stamped tags to both registries, syncs this overview to Docker Hub, and records upstream changes and fixed CVEs in `CHANGELOG.md`. Tool pins in the Dockerfile are advanced when a new upstream release passes the gates. No downgrades.

## Design decisions

- Debian stable slim is used instead of Alpine to follow the current base-image policy; the toolkit stays complete through distro packages plus verified static release binaries.
- The runtime stage is assembled from the same Debian base as the builder, so no foreign libc or musl-only dependency is introduced.
- The MOTD and license texts are files under `scripts/` rather than large inline heredocs, keeping the Dockerfile reviewable.
- The container keeps the upstream root default because network diagnostics often require capabilities; a prepared non-root user is documented and smoke-tested.
- ctop is compiled with its Docker connector (the primary use case). Its optional direct-runc connector is omitted because the upstream runc API it uses has no release that both compiles and carries every published security fix; all other tooling is unchanged.

## License

Packaging (Dockerfile, scripts, CI, documentation) is MIT, Copyright (c) 2026 Daniel G. Cosenza from FNX Labs. The netshoot-derived design is Apache License 2.0. Bundled third-party tools retain their own licenses; see `THIRD-PARTY-NOTICES.md` and `/usr/share/licenses/fnxnt/` inside the image.

## Credits

Maintainer: Daniel G. Cosenza from FNX Labs. Upstream project: https://github.com/nicolaka/netshoot. Thanks to all maintainers of the bundled open-source tools.
