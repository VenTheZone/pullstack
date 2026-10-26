# Working on this repo

Each folder in `skills/` is one skill. `pullstack/` holds everything the others share: `references/` for long method documents, `scripts/` for the sandbox, its image and the extractor. The smaller skills point at those files through `../pullstack/` and never copy them.

## Rules

- No harness-specific names or paths in any skill. A step that needs a tool says what kind of tool ("the harness's subagent tool"), not which product.
- A skill's `description` lists when to use it, never its steps. Write it as a folded block (`description: >`): a plain value containing `: ` is invalid YAML, and strict loaders drop the whole skill.
- Skills reference shared files by relative path from their own folder. Never an absolute path, never a path on one person's machine.
- Scripts run as `sh <path>` or `python3 -I <path>`. Installers may not keep the executable bit.
- Anything that opens an untrusted file runs through `scripts/sandbox.sh`. No host fallback.

## Checking a change

After changing the sandbox, image or extractor, rebuild the image and run the hostile-input tests:

```bash
docker image rm pullstack-sandbox:1
sh skills/pullstack/scripts/selftest.sh
```

Every line should print `ok`. The test leaves its files in `~/.cache/pullstack/work/selftest`; the next pullstack run clears them.
