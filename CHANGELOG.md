# Changelog

All notable changes to FNXNT (Fenix' Networking Tools) are documented here.

Format: Keep a Changelog. Semantic Versioning.

<!-- changelog:auto -->

## [1.0.16] — 2026-11-28

### Automated Daily Build
- Verified components: FNXNT `1.0.16`, Base OS `Debian 13.8 (stable-slim)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream changes:
  - **FNXNT:** `1.0.16` -> `1.0.16`
  - **Version changed:** `no`
  - **Base image:** `debian:13.8-slim` pinned at `sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0`
  - `bcicen/ctop`: pinned `n/a`; latest `v0.7.7`
  - `projectcalico/calico`: pinned `n/a`; latest `v3.33.1`
- Vulnerability gate: **0 fixable findings of any severity** in Trivy and Grype (SBOM scan) (82 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/fnxnt@sha256:eda233aff03eb9bee326d133253f26b53a62972a8654b6581c263cd84d71cf4f` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).

---

## [1.0.16] — 2026-11-27

### Automated Daily Build
- Verified components: FNXNT `1.0.16`, Base OS `Debian 13.8 (stable-slim)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream changes:
  - **FNXNT:** `1.0.16` -> `1.0.16`
  - **Version changed:** `no`
  - **Base image:** `debian:13.8-slim` pinned at `sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0`
  - `bcicen/ctop`: pinned `n/a`; latest `v0.7.7`
  - `projectcalico/calico`: pinned `n/a`; latest `v3.33.1`
- Vulnerability gate: **0 fixable findings of any severity** in Trivy and Grype (SBOM scan) (82 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/fnxnt@sha256:e4b58b15fcc9875f6dcd4060b534a9cb1ed721eedd2380885122e5cc837c5b0f` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
---

## [1.0.16] — 2026-11-26

### Automated Daily Build
- Verified components: FNXNT `1.0.16`, Base OS `Debian 13.8 (stable-slim)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream changes:
  - **FNXNT:** `1.0.16` -> `1.0.16`
  - **Version changed:** `no`
  - **Base image:** `debian:13.8-slim` pinned at `sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0`
  - `bcicen/ctop`: pinned `n/a`; latest `v0.7.7`
  - `projectcalico/calico`: pinned `n/a`; latest `v3.33.1`
- Vulnerability gate: **0 fixable findings of any severity** in Trivy and Grype (SBOM scan) (82 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/fnxnt@sha256:d12b1e8e3bfad863218a0596c4a0f66869ace2053945b228ad7d239e3ea23be6` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
---

## [1.0.16] - 2026-11-26

### Changed
- Rebased both build stages on `debian:13.8-slim` pinned by digest; Debian packages replace Alpine packages for the full netshoot-equivalent toolkit.
- All Go tools are compiled from official pinned sources with Go 1.27.4 and patched module versions to clear every fixable finding; Rust static tools and swaks remain SHA-256 verified.
- CI resolves the Debian base digest and FNXNT version, builds arm64 on a native runner, waits for Docker `healthy` on both architectures, and syncs the Docker Hub overview.

### Security
- Trivy + Grype hard gate: zero fixable findings of any severity on both architectures.

---

## [1.0.15] - 2026-11-25

### Changed
- Migrated to the dgcosenza/fnxnt-docker repository with full CI/CD, supply-chain hardening, and daily rebuilds.
- Updated calicoctl to v3.33.1, fortio to v1.77.0, websocat to v1.14.2, kubecolor to v0.9.0.
- kubectl resolves to the latest stable release (v1.37.3 at build time).
- MOTD and license documentation extracted into files under `scripts/`.

### Security
- Trivy + Grype gate: zero fixable Critical/High on both architectures.
- Non-root user `netuser` (UID 1000); capability-independent healthcheck.

---

## [1.0.14] - 2026-11-08

### Changed
- Base image updated to Alpine Linux 3.24.4.
- calicoctl upgraded to v3.33.0.
- fortio upgraded to v1.76.0.
- kubectl resolves to latest stable (v1.37.2).
- Windows variant synchronized to same tool pins.
- Documentation suite refreshed.

---

## [1.0.0] - 2025-10-01

### Added
- Initial FNXNT release forked from nicolaka/netshoot.
- Multi-stage build architecture reducing image size by ~40%.
- Oh My Zsh terminal environment with Agnoster theme.
- Custom interactive MOTD banner and quick-start guide.
- Non-root user support (netuser, UID 1000).
