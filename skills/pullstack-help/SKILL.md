---
name: pullstack-help
description: Use when the user asks how pullstack works, which pullstack skills exist, or what it needs — "/pullstack-help", "pullstack help", "what can pullstack do".
---

# Pullstack help

Show this card. Do not run anything.

## Skills

| Skill | Say | Does |
|---|---|---|
| `pullstack` | "pullstack <repo or app>", "take features from X" | Compares X with this project, ranks what to take, waits for your pick, plans and builds it |
| `pullstack-update` | "X shipped v2, anything new?" | Reports only what changed in X since the version you ported from |
| `pullstack-check` | "did this branch copy from X?" | Finds lines copied verbatim and checks licence and attribution |
| `pullstack-help` | "pullstack help" | This card |

## Targets

A repository (URL or path), or with no repo: an Electron app, website, HAR capture, `.zip`, APK, `.jar`, wheel, .NET assembly, PyInstaller or UPX-packed binary, native binary, archive or firmware image.

## Licence routes

| Upstream | Into a closed or permissive project |
|---|---|
| MIT, BSD, ISC, Apache-2.0, Unlicense, 0BSD | Copy, keeping notice and licence text |
| MPL-2.0 | Whole files, which stay MPL |
| LGPL | As a dependency |
| GPL, AGPL, none, closed app | Ideas only |

Not legal advice.

## Needs

- `git` and `python3`.
- No-repo targets: Docker with the gVisor `runsc` runtime, on a Linux host. The sandbox image builds itself on first use.

## Files

- Work: `~/.cache/pullstack/work/`, deleted once a report is written.
- Reports and plans: `~/.cache/pullstack/reports/`, cleared after 30 days.
