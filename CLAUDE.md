# Banking

Personal finance app: import bank CSV exports (DKB for now), categorise transactions by rules, and analyse income and spending. Single user, self-hosted.

## Stack

- Ruby 3.4.9, Rails 8.1, SQLite
- Hotwire (Turbo + Stimulus), importmap, Tailwind
- Phlex for views and components, Oaken for fixtures and seeds, RSpec for tests (all being set up in #20; Minitest until then)
- Solid Queue, Solid Cache, Solid Cable
- Kamal for deployment

## Commands

- `bin/setup` – install dependencies and prepare the database
- `bin/dev` – run the app with the Tailwind watcher
- `bin/rails test [path:line]` – run tests (`bundle exec rspec [path:line]` after #20)
- `bin/rubocop [-a]` – lint (and autocorrect)
- `bin/ci` – full local CI, steps in `config/ci.rb`

## Workflow

- Issues live in `LaurinKerkloh/banking`, grouped by milestones per phase.
- Labels: `needs-plan` → `planned`, plus `feature` / `infra` / `workflow`.
- Flow: `/create-issue` → `/plan-issue` → `/implement-issue` → user merges → `/cleanup`
- Each implementation runs in its own worktree, created with `EnterWorktree`.

## Rules

- English everywhere: docs, issues, PRs, commits, code.
- No implementation without the `planned` label and an approved plan in the issue.
- TDD: write the failing test first.
- The repo is public: never commit real bank exports or personal data.

## Code conventions

- Comments only for the non-obvious why, never restating the code. This includes config files.
