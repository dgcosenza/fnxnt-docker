# Security Policy

Maintained by **Daniel G. Cosenza from FNX Labs**.

## Supported Versions

Only the latest daily build (`latest`) receives security updates. Immutable date-stamped tags (`<version>-YYYYMMDD`) are frozen for reproducibility.

## Vulnerability Scanning & Gates

- **Trivy** (OS + packages): SARIF uploaded to GitHub Code Scanning; table and JSON reports retained for 90 days; **blocking hard gate** on any fixable vulnerability of any severity.
- **Grype**: **blocking hard gate** (`--only-fixed --fail-on negligible`, all severities); table report retained for 90 days.
- **SBOM & Provenance**: SPDX-JSON SBOM via Syft plus provenance JSON retained for 90 days.
- **Hadolint**, **Gitleaks**, **public-check** run on every push and pull request.

## Reporting a Vulnerability

**Do not open a public issue** for security vulnerabilities.

Report privately through GitHub Security Advisories: https://github.com/dgcosenza/fnxnt-docker/security/advisories/new

For upstream netshoot vulnerabilities, follow the upstream project's security process: https://github.com/nicolaka/netshoot.
