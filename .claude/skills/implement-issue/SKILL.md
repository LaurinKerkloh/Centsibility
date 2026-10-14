---
name: implement-issue
description: Implement a planned GitHub issue autonomously in its own worktree, test-first, and open a pull request with green CI. Use when the user wants to implement an issue that has the planned label.
argument-hint: <issue number>
---

# Implement issue

Once the plan is approved, work autonomously. Don't ask for step-by-step confirmation.

1. Read the issue with `gh issue view <n>`. Stop if it isn't `planned` (suggest `/plan-issue`), or if an issue under "Depends on" is still open (report which ones).
2. Call `EnterWorktree` with name `<n>-<slug>`. It branches from `origin/main`, copies the files listed in `.worktreeinclude`, and moves the session into the worktree. Then, inside it:

   ```sh
   git branch -m <n>-<slug>
   bin/setup --skip-server
   ```

3. Implement test-first, with logical commits.
4. Deviations from the plan:
   - Small ones: make them and note them for the PR.
   - Big ones (scope, data model, behaviour): stop, update the plan in the issue together with the user, then continue.
5. Run `/simplify`.
6. Run `/code-review`. Fix every valid finding, and keep track of what was fixed and what was skipped, with the reason.
7. `bin/ci` must pass.
8. Push and open the PR with `gh pr create`. Body:

   ```markdown
   Closes #<n>

   ## What changed
   ## Deviations from plan    (or "None")
   ## Review findings         (fixed, and skipped with reason)
   ## How it was tested
   ```

9. Watch CI with `gh pr checks --watch`. Fix and push until it's green.
10. Report the PR link and a summary in the chat.
