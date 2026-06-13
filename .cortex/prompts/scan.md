[Goal]
Surface actionable security and correctness vulnerabilities across the repository's
Python codebase as [coco-agent] issues that the fix agent can resolve autonomously
without further clarification.

[Requirements]
- Identify security vulnerabilities: SQL injection, hardcoded credentials, insecure authentication
- Identify correctness issues: wrong column/variable names, undefined references, logic errors
- Scan all Python files in the repository
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
