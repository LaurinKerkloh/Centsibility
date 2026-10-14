---
name: plan-issue
description: Build a complete implementation plan for a GitHub issue together with the user and write it into the issue. Use when an issue has the needs-plan label or the user wants to plan or revise the plan for an issue.
argument-hint: <issue number>
---

# Plan issue

The goal is a fully shared understanding of the issue and the solution. Never fill gaps with your own assumptions.

1. Read the issue with `gh issue view <n>`. If it is already `planned`, ask whether to revise the plan or abort.
2. **Ask first:** ask about intent and expected behaviour, in rounds of multiple-choice questions with a recommendation where there is one.
3. **Investigate later:** read the relevant code and related issues, run checks, share the findings, then ask follow-up rounds.
4. Repeat until a plan can be written without any assumptions.
5. Show the full new issue body in the chat. Only after the user's OK, rewrite the body (`gh issue edit <n> --body-file`) and swap the labels (`--remove-label needs-plan --add-label planned`).

## Body format

```markdown
## Goal
## Acceptance criteria
## Current state     (only if relevant)
## Decisions         (big ones only: scope, data model, behaviour)
## Plan              (concrete steps with files, commands, and snippets where they remove ambiguity)
## Out of scope
```

Don't list test cases; they follow from the acceptance criteria.
