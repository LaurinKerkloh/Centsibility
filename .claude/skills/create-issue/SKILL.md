---
name: create-issue
description: Create a new GitHub issue in LaurinKerkloh/banking with goal, scope, milestone, labels and dependencies. Use when the user wants to capture a new feature, task or idea as an issue.
---

# Create issue

1. Ask only the questions needed to write the goal and scope.
2. Read the existing milestones and issues (`gh api repos/{owner}/{repo}/milestones`, `gh issue list --state all`) to choose the milestone, the type label (`feature` / `infra` / `workflow`) and dependencies. Ask if any of these is unclear.
3. Write the body:

   ```markdown
   ## Goal
   ## Scope
   ## Depends on        (only if any)
   ## Open questions    (only if any)

   ---
   _Detailed implementation plan to be added before implementation (see `needs-plan` label)._
   ```

4. Create the issue directly with `gh issue create`, labels `needs-plan` plus the type label, and the milestone.
5. Reply with the link and the chosen milestone, labels and dependencies.
