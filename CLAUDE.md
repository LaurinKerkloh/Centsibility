# Banking

Personal finance app: import bank CSV exports (DKB for now), categorise transactions by rules, and analyse income and spending. Single user, self-hosted.

## Stack

- Ruby 3.4.9, Rails 8.1, SQLite
- Hotwire (Turbo + Stimulus), importmap, Tailwind
- Phlex for views and components, Oaken for fixtures and seeds
- RSpec with Capybara and Selenium (headless Chrome) for tests
- Standard for linting, run through RuboCop
- Solid Queue, Solid Cache, Solid Cable
- Kamal for deployment

## Commands

- `bin/setup` – install dependencies and prepare the database
- `bin/dev` – run the app with the Tailwind watcher
- `bundle exec rspec [path:line]` – run specs
- `bin/rubocop [-a]` – lint with Standard (and autocorrect)
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
- Views and components are Phlex only: pages are `Views::*` in `app/views`, components are `Components::*` in `app/components`. ERB only for mailer layouts and PWA templates.
- Pages set their title with `page_title`; `Views::Base` wraps every page in `Components::Layout`.
- Tailwind as plain class strings.
- Seeds live in `db/seeds` (Oaken); env-specific ones go in `db/seeds/development` and `db/seeds/test`. Specs use the same seeds.
