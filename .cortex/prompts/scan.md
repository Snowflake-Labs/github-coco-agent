[Goal]
Surface actionable security and correctness vulnerabilities across the repository's
Python codebase as issues that the fix agent can resolve autonomously without further
clarification, structured to minimise fix conflicts when multiple agents run in parallel.
Decide per issue whether to auto-fix or request human review based on scoring and the
team's configured fix ceiling.

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
- Emit security issues before correctness issues (P0 security, P1 correctness).
  This ensures serial fix agents tackle the dangerous bugs first.
- If no actionable issues are found, exit cleanly without creating any issues

Fix-mode routing:
Each issue must be assessed against three risk dimensions and routed to either
auto-fix or human review according to the team ceiling in `$COCO_MAX_AUTO`
(default: `conservative` when unset).

Risk dimensions — score each finding:
  SEVERITY:   critical | high | medium | low
  COMPLEXITY: high | medium | low
    low:    single file, 1-5 lines changed, no branching logic change
    medium: 1-2 files, 5-20 lines, or conditional logic change
    high:   3+ files, 20+ lines, or architectural/async change
  CONFIDENCE: high | medium | low  (certainty about the correct fix)

Routing policy by ceiling:
  off:          → needs-review for all issues
  aggressive:   → auto-fix when CONFIDENCE >= medium
  conservative: → auto-fix only when SEVERITY=low AND COMPLEXITY=low AND CONFIDENCE=high
                   all other combinations → needs-review

[Output]
Before creating any issue, fetch existing open coco-agent issues once to prevent duplicates:
  OPEN_TITLES=$(gh issue list --label coco-agent --state open \
    --json title --jq '.[].title' 2>/dev/null || echo "")

For each issue found, in priority order (security first), check before creating:
  TITLE="<the title you are about to create>"
  if echo "$OPEN_TITLES" | grep -qF "$TITLE"; then
    echo "SKIP (already open): $TITLE"
  else
    <proceed with gh issue create below>
  fi

  If FIX_DECISION == "auto-fix":
    gh issue create \
      --title "[coco-agent] Bug: <short description>" \
      --body "<file>:<function>\n\nCode: <problematic snippet>\nProblem: <why it is a bug>\nExpected: <what the correct behaviour should be>\n\n---\n_Severity: SEVERITY | Complexity: COMPLEXITY | Confidence: CONFIDENCE | Fix mode: auto_" \
      --label "coco-agent" \
      --label "coco:auto-fix" \
      --label "coco-agent-security"  # or coco-agent-correctness

  If FIX_DECISION == "needs-review":
    gh issue create \
      --title "Bug: <short description>" \
      --body "<file>:<function>\n\nCode: <problematic snippet>\nProblem: <why it is a bug>\nExpected: <what the correct behaviour should be>\n\n---\n_Severity: SEVERITY | Complexity: COMPLEXITY | Confidence: CONFIDENCE | Fix mode: needs-review_\n_To trigger fix: comment `/coco fix` on this issue._" \
      --label "coco:needs-review" \
      --label "coco-agent-security"  # or coco-agent-correctness

Final stdout summary (always print, even when zero issues):
  "Scan complete. Found N issue(s) [auto-fix: X, needs-review: Y] [P0: A security, P1: B correctness]. Ceiling: COCO_MAX_AUTO"  — or —
  "Scan complete. No actionable issues found."
