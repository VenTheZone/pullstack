# Installing pullstack

## With the skills CLI

The [skills CLI](https://github.com/vercel-labs/skills) installs into most agents' skill folders.

```bash
npx skills add VenTheZone/pullstack -g          # choose skills and agents interactively
npx skills add VenTheZone/pullstack -g --all    # every skill, every agent it detects
```

Update with `npx skills update -g`. Remove with `npx skills remove VenTheZone/pullstack -g`.

## By hand

```bash
git clone https://github.com/VenTheZone/pullstack.git
cp -R pullstack/skills/* ~/.agents/skills/
```

`~/.agents/skills` is read by many agents. If yours reads a different folder, copy into that one. Keep the four folders side by side: `pullstack-update` and `pullstack-check` use files inside `pullstack/`.

To update, `git pull` and copy again.

## Requirements

- `git` and `python3`.
- For targets with no repo: Docker with the gVisor `runsc` runtime, on a Linux host. Follow the [gVisor install guide](https://gvisor.dev/docs/user_guide/install), then check that Docker sees it:

  ```bash
  docker info --format '{{json .Runtimes}}' | grep -q runsc && echo ready
  ```

  The sandbox image `pullstack-sandbox:1` (about 950 MB) builds itself the first time it is needed. That build is the only step that uses the network; the sandbox itself has none.

Without Docker and gVisor, repo targets still work. No-repo targets stop with a message rather than unpacking anything outside the sandbox.

## Removing everything

1. Remove the skills: `npx skills remove VenTheZone/pullstack -g`, or delete the four folders.
2. Remove the image: `docker image rm pullstack-sandbox:1`.
3. Remove reports and work: delete `~/.cache/pullstack`.
