---
name: pullstack-check
description: Use when the user asks whether existing code was copied from another project, or whether a port is licence-clean — "did this branch/PR copy from X?", "check our port of X", "is this licence-safe?", or before merging work that learned from an outside project.
---

# Pullstack check

Audit a branch or pull request that took ideas or code from another project: verbatim lines, licence route, attribution.

`<pullstack>` below is the `pullstack` skill folder installed next to this one (`<this skill dir>/../pullstack`).

## Inputs

- The work to check: a branch or PR. Default is the current branch against the default branch.
- The upstream: URL plus commit, or the artifact. Unknown → ask; never guess which project it came from.

## Steps

1. **Fetch upstream, read-only,** into `~/.cache/pullstack/work/<name>`. Repo: clone at the commit. Artifact: unpack through `<pullstack>/scripts/sandbox.sh`, following `<pullstack>/references/artifact-route.md`.
2. **Licence route** from "Licence routes" in `<pullstack>/SKILL.md`, for this upstream against this project.
3. **Copy check** from `<pullstack>/references/build.md` over the whole change: use `git diff <base>...<branch> -U0` in place of `git diff main -U0`.
4. **Judge each flagged line.** An import, a standard API call or common boilerplate is fine. A function body, a comment, a string table or test data is copied.
5. **Attribution.** Route allows copying and something was copied → the upstream copyright notice and licence text must ship with this project (a notices file, or a header in the copied file). Missing is a finding.
6. **Delete** the work folder.

## Report

Reply directly; this is short.

- Verdict: `clean`, `needs attribution`, or `must rewrite`.
- One line per finding: `path:line — what was copied — fix`.
- Not checked: say so when upstream was minified, and always add that a rewrite with renamed identifiers passes a line match. The check catches pasting, not close translation; that needs a reader. Not legal advice.
