# Changelog

All notable changes to FNXNT (Fenix' Networking Tools) are documented here.

Format: Keep a Changelog. Semantic Versioning.

<!-- changelog:auto -->

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
