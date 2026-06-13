[Goal]
Surface actionable security and correctness vulnerabilities across the repository's
Python codebase as [coco-agent] issues that the fix agent can resolve autonomously
without further clarification, structured to minimise fix conflicts when multiple
agents run in parallel.

[Requirements]
- Read `.agentignore` from the repository root before scanning, if it exists.
  Parse it as gitignore-style patterns (lines starting with # are comments;
  blank lines are ignored). Skip any files or directories matching these patterns.
  If `.agentignore` does not exist, scan all Python files.
- Identify security vulnerabilities: SQL injection, hardcoded credentials, insecure authentication
- Identify correctness issues: wrong column/variable names, undefined references, logic errors
- Scan all Python files in the repository that are not excluded by `.agentignore`
- Issue body must include: file path, line number, the problematic code snippet,
  why it is a problem, and what a correct fix should look like (without writing the fix)

[Constraints]
Issue splitting rules (least-conflict path):
- One issue per distinct location (file + function/line range).
  The same bug pattern in two different functions = two separate issues.
- Exception: if two bugs are inside the same function body, combine them into
  one issue. Their fixes would overlap; a single PR is safer.
- Do not raise issues for style preferences, formatting, or minor readability concerns
- Issue descriptions must be precise and self-contained so the fix agent needs no follow-up

Ordering and labels:
- Emit security issues before correctness issues (P0 security, P1 correctness).
  This ensures serial fix agents tackle the dangerous bugs first.
- Apply two labels to every issue: "coco-agent" (trigger label) and either
  "coco-agent-security" or "coco-agent-correctness" (category label).
- If no actionable issues are found, exit cleanly without creating any issues

[Output]
For each issue found, in priority order (security first):
  gh issue create \
    --title "[coco-agent] Bug: <short description>" \
    --body "<file>:<function>\n\nCode: <problematic snippet>\nProblem: <why it is a bug>\nExpected: <what the correct behaviour should be>" \
    --label "coco-agent" \
    --label "coco-agent-security"  # or coco-agent-correctness

Final stdout summary (always print, even when zero issues):
  "Scan complete. Found N issue(s) [P0: X security, P1: Y correctness]: [titles]"  — or —
  "Scan complete. No actionable issues found."
