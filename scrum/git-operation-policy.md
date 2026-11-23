## PR Label Rules (for GitHub Copilot Coding Agent)

If an issue has a `sprint/*` or `test/*` label, apply the same label to the PR.
The PR body must include the related issue number in the form `Fixes #<issue-number>`.

## Sprint Branch Rules

Each sprint works on one branch, `sprintNNN`, created from an up-to-date `main` at sprint start. Agents work in the same directory under the file-ownership table of the sprint plan. Commit and push to the sprint branch often. After the retrospective is approved, merge the branch into `main` and push `main`.
