# Agent and Contributor Conventions

Guidelines for CoCo agent behaviour, commit style, and prompt conventions in this repo.

## Commit Style

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short description>
```

Common types: `feat`, `fix`, `chore`, `docs`, `ci`, `refactor`

Examples:
- `fix(scan): correct issue title prefix`
- `ci(workflows): update scan job image`
- `chore: update dependencies`

The `cortex-fix.yml` workflow uses this style when opening PRs automatically.

## Issue and Label Conventions

The scan workflow creates issues in two categories:

**Auto-fix** — labeled `coco:auto-fix`:
- Title: `[coco-agent] Bug: <short description>`
- The `coco:auto-fix` label triggers `cortex-fix.yml` automatically

**Needs review** — labeled `coco:needs-review`:
- Title: `Bug: <short description>`
- A developer reviews and comments `/coco fix` to trigger the fix

## Fix PR Conventions

A good fix PR opened by the agent should:
- Reference the issue it fixes (PR body includes `#<issue-number>`)
- Contain only the minimal change needed to fix the reported issue
- Commit message: `fix(coco-agent): <issue title> [skip ci]`

## scan.md / fix.md Conventions

`scan.md` instructs the agent to:
- Discover Python files using Glob, respecting `.agentignore` patterns
- Score each finding (severity × complexity × confidence)
- Route to `coco:auto-fix` or `coco:needs-review` based on `COCO_MAX_AUTO` ceiling
- Create one issue per distinct location (file + function/line range)

`fix.md` instructs the agent to:
- Read the triggering issue title and body
- Locate the relevant code
- Apply the minimal fix — no unrelated changes
- Commit to a new `coco/fix-<run-id>` branch and open a PR

## Secret and Resource Naming

All GitHub secrets follow the pattern `SNOWFLAKE_<RESOURCE>`.
All Snowflake resource names follow `<PREFIX>_GH_<REPO>_COCO_AGENT_<RESOURCE>`.
The prefix isolates resources per deployment so multiple instances can coexist
in the same Snowflake account.
