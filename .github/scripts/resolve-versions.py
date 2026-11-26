#!/usr/bin/env python3
"""Resolve FNXNT build metadata (version is pinned in the Dockerfile)."""

from __future__ import annotations

import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path

VERSION_RE = re.compile(r"^ARG FNXNT_VERSION=(.+)$", re.MULTILINE)


def main() -> None:
    dockerfile = Path("Dockerfile").read_text(encoding="utf-8")
    m = VERSION_RE.search(dockerfile)
    if not m:
        raise SystemExit("ERROR: FNXNT_VERSION not found in Dockerfile")
    fnxnt_version = m.group(1).strip().strip('"')

    override = os.environ.get("OVERRIDE_SAMBA", "").strip()
    if override:
        fnxnt_version = override

    build_date = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    build_date_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    prev = {}
    vpath = Path("versions.json")
    if vpath.exists():
        try:
            prev = json.loads(vpath.read_text(encoding="utf-8"))
        except Exception:
            prev = {}

    changed = fnxnt_version != prev.get("fnxnt_version", "")

    md = [
        "# Upstream changes — FNXNT",
        "",
        f"- **FNXNT:** `{prev.get('fnxnt_version', 'none')}` -> `{fnxnt_version}`",
        f"- **Version changed:** `{'yes' if changed else 'no'}`",
        "",
    ]
    Path("upstream-changes.md").write_text("\n".join(md), encoding="utf-8")

    outputs = {
        "samba_version": fnxnt_version,
        "samba_deb_version": "n/a",
        "debian_base": "alpine:3.24.4",
        "base_digest": "",
        "build_date": build_date,
        "build_date_iso": build_date_iso,
        "created": build_date_iso,
    }
    gh_out = os.environ.get("GITHUB_OUTPUT")
    if gh_out:
        with open(gh_out, "a", encoding="utf-8") as fh:
            for k, v in outputs.items():
                fh.write(f"{k}={v}\n")
    for k, v in outputs.items():
        print(f"{k}={v}")


if __name__ == "__main__":
    raise SystemExit(main())
PY
echo done