---
name: pullstack-update
description: Use when a project the user already pulled features from has a newer version, and they ask what changed since — "X shipped v2, anything worth taking?", "re-check X", "what's new in X since we ported", "update our port of X".
---

# Pullstack update

Report only what an upstream gained, changed or removed since the version this project last learned from.

`<pullstack>` below is the `pullstack` skill folder installed next to this one (`<this skill dir>/../pullstack`). This skill reuses its brief, sandbox and build steps.

## Steps

1. **Find the baseline.** The old report, `~/.cache/pullstack/reports/<name>.md`, records the old SHA or SHA-256 in its Snapshot. No report → ask the user for the old version (tag, commit, or the old artifact). Nothing known → run `pullstack` instead; there is no baseline to diff.
2. **Re-check the licence** of the new version. Projects relicense. New features follow the new licence's route; code already copied keeps the terms it was copied under.
3. **Fetch both versions** into `~/.cache/pullstack/work/<name>-old` and `<name>-new`, by the rules of `pullstack` step 2. Artifacts are unpacked through `<pullstack>/scripts/sandbox.sh`.
4. **Narrow before reading.**
   - Repo: in one clone, fetch both commits (`git fetch --depth 1 origin <sha>`, once per side), then `git diff --stat <old> <new>`.
   - Artifact: follow "Two builds of one app" in `<pullstack>/references/artifact-route.md`.
   - Changelogs and release notes are leads to check, never evidence.
5. **Dissect the changed areas only**, with the brief from `<pullstack>/SKILL.md`. Set Focus to `changes between <old> and <new>`, and add: "Matrix rows are only features added, changed or removed between the two versions. For each changed feature this project already ported, say whether the port needs the change." Delete both work folders once the report is written.
6. **Continue with `pullstack` steps 5 to 7**: the user picks, then plan and build.

## Common mistakes

| Mistake | Fix |
|---|---|
| Re-listing features that were already there | Rows cover the diff between the two versions only |
| Taking the changelog's word | Cite the changed code |
| Assuming the old licence still holds | Step 2 |
