---
name: cleanup
description: Remove worktrees and local branches whose pull requests are merged, then update main. Use after the user has merged a PR or asks to clean up.
---

# Cleanup

1. Get the merged PRs in one call (`gh pr list --state merged --limit 100 --json headRefName,headRefOid`) and match them against the local branches and `git worktree list --porcelain`. A branch only counts as merged if its tip equals the PR's `headRefOid`; otherwise it has new work (or a reused name) and is skipped and reported. Squash merges don't show up in `git branch --merged`, so ask GitHub.
2. Remove those worktrees (`git worktree remove <path>`) and delete those branches (`git branch -D <branch>`). A worktree with uncommitted changes is skipped and reported, never force-removed.
3. In the main checkout, switch to `main` and pull.
4. Report what was removed and what was skipped.
