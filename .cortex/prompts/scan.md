[Goal]
Surface actionable security and correctness vulnerabilities across the repository's
Python codebase as [coco-agent] issues that the fix agent can resolve autonomously
without further clarification.

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
- One issue per root cause — do not create duplicate issues for the same underlying problem
- Do not raise issues for style preferences, formatting, or minor readability concerns
- Issue descriptions must be precise and self-contained so the fix agent needs no follow-up
- Use the label "coco-agent" on every issue created
- If no actionable issues are found, exit cleanly without creating any issues

[Output]
For each issue found:
  gh issue create \
    --title "[coco-agent] Bug: <short description>" \
    --body "<file>:<line>\n\nCode: <problematic snippet>\nProblem: <why it is a bug>\nExpected: <what the correct behaviour should be>" \
    --label "coco-agent"

Final stdout summary (always print, even when zero issues):
  "Scan complete. Found N issue(s): [titles]"  — or —
  "Scan complete. No actionable issues found."
