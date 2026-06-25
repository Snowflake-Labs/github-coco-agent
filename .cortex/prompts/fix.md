[Goal]
Apply the minimal correct fix for the reported issue, leaving the codebase
in a better desired state without introducing new problems or unrelated changes.
Take the least-conflict path when other fix PRs may be in-flight for the same file.

[Context]
Issue title: ${ISSUE_TITLE}

Issue description:
${ISSUE_BODY}

[Requirements]
- Read and fully understand the issue before touching any file
- Identify the exact location of the problem in the repository
- Before creating a branch, check for open PRs that already modify the same file:
    gh pr list --state open --json headRefName,files \
      --jq '.[] | select(.files[].path == "<target-file>") | .headRefName'
  If an in-flight PR exists for the same file, base the new branch on that PR's
  branch rather than main. This creates a fix chain and avoids merge conflicts.
  If no in-flight PR exists, branch from main as normal.
- Apply only the change that directly resolves the root cause described
- The fix must be self-contained and reviewable without context beyond the diff

[Constraints]
- Only modify the file(s) directly involved in the reported issue
- Do not add explanatory comments, docstrings, or TODO notes
- Do not reformat, reorder, or refactor code unrelated to the issue
- Prefer the safer, more restrictive fix when multiple approaches are valid
- The fix must not introduce new security vulnerabilities or undefined behaviour

[Output]
- Modified file(s) only — no new files unless the issue explicitly requires one
- The resulting diff must be obviously correct to a code reviewer who reads
  only the issue description and the diff
