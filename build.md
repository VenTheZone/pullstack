# Plan and build

Read at step 6, once the user has picked features. Everything here works with or without a subagent tool; without one, "subagent" means a fresh session given only the text named.

## Plan

Write `~/.cache/pullstack/reports/<name>-plan.md`. One task per picked feature, smallest-dependency first, each leaving the project working. Per task:

- **Goal**: one sentence a user would notice.
- **Route**: `reimplement`, or `copy (<licence>, notice in <file>)`.
- **Learns from**: upstream `path:line` for the behaviour and edge cases to match.
- **Lands in**: the exact files here, and the existing helpers to reuse, by `path:line`.
- **Done when**: the check that proves it, as a command and its expected result. Written before any code.
- **Size**: S, M or L.

Show the plan and wait for the user's go-ahead. A task the user drops is deleted from the plan, not left half-built.

## Build

1. **Isolate.** `git worktree add ../<project>-pullstack-<name> -b pullstack/<name>`. The user's checkout stays untouched until they merge.
2. **One task at a time.** Give the implementer only that task's text, the report rows it cites, and the route. Never the whole report. The implementer writes the check first, sees it fail, makes it pass, runs the project's own tests and type check, and commits once.
3. **Review before the next task**, by a different subagent, in this order:
   - Does it do what the task says, and nothing beyond it?
   - Was the route kept? A `copy` task carries the notice and licence text. A `reimplement` task carries no upstream text; run the copy check below.
   - Is it code this project would accept: its patterns, its helpers, no dead branches?
4. **Fix loop.** Findings go back to the implementer, then review again. Three rounds without a clean review: stop and ask the user.
5. **Finish.** Review the whole branch once, run the full test suite, then tell the user the branch name, one line per feature, and anything dropped. Merging is the user's call. Remove the worktree and the plan when they merge or drop the branch.

A task that needs upstream again re-fetches it at the recorded SHA (`git init <dir> && git -C <dir> fetch --depth 1 <url> <sha> && git -C <dir> checkout -q FETCH_HEAD`) or re-extracts the artifact and checks its SHA-256, into `~/.cache/pullstack/work/<name>`, and deletes it when the task ends.

## Copy check (reimplement tasks)

Lines of 40+ characters that appear both in the task's diff and in upstream:

```sh
w=~/.cache/pullstack/work/<name>
git diff main -U0 | sed -n 's/^+[[:space:]]*//p' | awk 'length >= 40' | sort -u > "$w.new"
find "$w" -type f -exec sed 's/^[[:space:]]*//' {} + | awk 'length >= 40' | sort -u > "$w.up"
comm -12 "$w.new" "$w.up"; rm -f "$w.new" "$w.up"
```

No output: no verbatim lines. Output: the reviewer reads each. An import line or a standard API call is fine; a function body, a comment or a string table means the task copied, and it is rewritten or moved to the `copy` route if the licence allows.
