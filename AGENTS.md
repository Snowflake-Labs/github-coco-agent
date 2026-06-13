# Agent & Contributor Conventions

This file documents conventions for both human contributors and AI agents working
in this repository.

## Commit Style

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short description>
```

Common types: `feat`, `fix`, `chore`, `docs`, `ci`, `refactor`

Examples:
- `feat(demo): add demo app with coco-agent scan triggers`
- `fix(scan): correct issue title prefix`
- `ci(workflows): update scan job image`

The coco-agent fix workflow uses this style when opening PRs automatically.

## scan.md / fix.md Conventions

**scan.md** instructs the agent to scan the repository for issues. Issues it creates must:
- Have titles starting with `[coco-agent]` — this is required for the fix workflow to trigger
- Include a clear, actionable description of the problem
- Reference the file and line number where possible

**fix.md** instructs the agent to fix an open `[coco-agent]` issue. PRs it opens must:
- Reference the issue number in the PR description
- Contain only the minimal change needed to fix the reported issue
- Pass any existing linting/test checks

## What Makes a Good Demo Issue

The demo app (`app.py`) contains three intentional issues:
1. Hardcoded schema name — should be configurable via environment
2. Password authentication — should use `WORKLOAD_IDENTITY` or `externalbrowser`
3. SQL injection via f-string — should use parameterized queries

A well-formed scan issue title looks like:
`[coco-agent] Bug: SQL injection risk in query_table() — app.py:28`

## CI/CD Secret Conventions

All GitHub secrets follow the pattern `SNOWFLAKE_<RESOURCE>`.
All Snowflake resource names follow `<PREFIX>_GITHUB_COCO_AGENT_<RESOURCE>`.
The prefix isolates resources per deployment so multiple instances can coexist
in the same Snowflake account.
