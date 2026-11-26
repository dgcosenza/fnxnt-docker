#!/usr/bin/env python3
"""Resolve the FNXNT build metadata and the pinned Debian stable base digest.

The image version is pinned in the Dockerfile and can be overridden by the
workflow_dispatch input. Tool versions are pinned in the Dockerfile and checked
against the authenticated GitHub releases API on every run; new releases are
reported in the upstream changes artifact so the pins can be advanced.
"""

from __future__ import annotations

import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path
from urllib.request import Request, urlopen

DEBIAN_TAG = "13.8-slim"
VERSION_RE = re.compile(r"^ARG FNXNT_VERSION=(.+)$", re.MULTILINE)
TOOL_PINS = {
    "bcicen/ctop": "CTOP_VERSION",
    "projectcalico/calico": "CALICO_VERSION",
    "gcla/termshark": "TERMSHARK_VERSION",
    "fullstorydev/grpcurl": "GRPCURL_VERSION",
    "fortio/fortio": "FORTIO_VERSION",
    "vi/websocat": "WEBSOCAT_VERSION",
    "fujiapple852/trippy": "TRIPPY_VERSION",
    "kubecolor/kubecolor": "KUBECOLOR_VERSION",
    "ahmetb/kubectx": "KUBECTX_VERSION",
    "int128/kubelogin": "KUBELOGIN_VERSION",
    "mikefarah/yq": "YQ_VERSION",
}


def fetch_json(url: str, token: str = "") -> dict:
    headers = {"Accept": "application/vnd.github+json", "User-Agent": "dgcosenza-fnxnt-docker-ci"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    with urlopen(Request(url, headers=headers), timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def pinned_arg(dockerfile: str, name: str) -> str:
    m = re.search(rf"^ARG {re.escape(name)}=(.+)$", dockerfile, re.MULTILINE)
    return m.group(1).strip().strip('"') if m else ""


def main() -> None:
    dockerfile = Path("Dockerfile").read_text(encoding="utf-8")
    m = VERSION_RE.search(dockerfile)
    if not m:
        raise SystemExit("ERROR: FNXNT_VERSION not found in Dockerfile")
    fnxnt_version = m.group(1).strip().strip('"')

    override = os.environ.get("OVERRIDE_FNXNT", "").strip()
    if override:
        fnxnt_version = override

    token = os.environ.get("GH_TOKEN", "")
    if not token:
        raise SystemExit("ERROR: GH_TOKEN is required for authenticated release resolution")

    hub = fetch_json(f"https://hub.docker.com/v2/repositories/library/debian/tags/{DEBIAN_TAG}")
    base_digest = (hub.get("digest") or "").strip()
    if not base_digest.startswith("sha256:"):
        raise SystemExit(f"ERROR: could not resolve a digest for debian:{DEBIAN_TAG}")
    debian_base = f"debian:{DEBIAN_TAG}@{base_digest}"

    now = datetime.now(timezone.utc)
    build_date = now.strftime("%Y-%m-%d")
    created = now.strftime("%Y-%m-%dT%H:%M:%SZ")

    pins = {repo: pinned_arg(dockerfile, arg) for repo, arg in TOOL_PINS.items()}
    releases: dict[str, str] = {}
    for repo in TOOL_PINS:
        try:
            releases[repo] = (fetch_json(f"https://api.github.com/repos/{repo}/releases/latest", token).get("tag_name") or "").strip()
        except Exception:
            releases[repo] = ""

    prev = {}
    vpath = Path("versions.json")
    if vpath.exists():
        try:
            prev = json.loads(vpath.read_text(encoding="utf-8"))
        except Exception:
            prev = {}
    prev_version = prev.get("fnxnt_version", "")
    prev_base = prev.get("base_digest", "")
    changed = fnxnt_version != prev_version
    base_changed = base_digest != prev_base

    lines = [
        "# Upstream changes — FNXNT on Debian stable",
        "",
        f"- **FNXNT:** `{prev_version or 'none'}` -> `{fnxnt_version}`",
        f"- **Version changed:** `{'yes' if changed else 'no'}`",
        f"- **Base image:** `debian:{DEBIAN_TAG}` pinned at `{base_digest}`"
        + (" (refreshed)" if base_changed else ""),
        "",
        "## Pinned tool releases",
        "",
    ]
    for repo, pin in pins.items():
        latest = releases.get(repo, "")
        note = " (up to date)" if latest and latest.lstrip("v") == pin.lstrip("v") else ""
        lines.append(f"- `{repo}`: pinned `{pin or 'n/a'}`; latest `{latest or 'unavailable'}`{note}")

    Path("upstream-changes.md").write_text("\n".join(lines) + "\n", encoding="utf-8")

    outputs = {
        "fnxnt_version": fnxnt_version,
        "debian_base": debian_base,
        "base_digest": base_digest,
        "build_date": datetime.now(timezone.utc).strftime("%Y%m%d"),
        "build_date_iso": build_date,
        "created": created,
    }
    gh_out = os.environ.get("GITHUB_OUTPUT")
    if gh_out:
        with open(gh_out, "a", encoding="utf-8") as fh:
            for key, value in outputs.items():
                fh.write(f"{key}={value}\n")
    for key, value in outputs.items():
        print(f"{key}={value}")


if __name__ == "__main__":
    raise SystemExit(main())
