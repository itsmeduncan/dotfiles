# Profile-Wide Instructions

Personal coding preferences that apply to all projects.

## Environment

- macOS Apple Silicon, zsh, Ghostty terminal, tmux
- Editor: Neovim (aliased as `vim` and `vi`)
- Package managers: Homebrew, mise (runtimes), uv (Python), pnpm (Node.js)
- Git: delta pager, rebase workflow, `gh` CLI for GitHub

## Stack

- **Python:** uv for packaging, ruff for linting/formatting, pytest for testing, pyright for types
- **Node.js/TypeScript:** pnpm, Next.js/React, ESLint, Prettier
- **iOS:** Swift, SwiftUI, Xcode, swiftlint, cocoapods
- **Android:** Kotlin, Jetpack Compose, Gradle
- **Infrastructure:** Docker Compose, direnv for env management

## Coding Preferences

- Write concise, readable code. Favor clarity over cleverness.
- Use modern language features — f-strings in Python, optional chaining in TypeScript, structured concurrency in Swift.
- Prefer composition over inheritance.
- Functions should do one thing. If a function needs a comment explaining what a section does, that section should be its own function.
- Error messages should be actionable — say what went wrong AND what to do about it.
- Tests should be fast, isolated, and test behavior not implementation.

## Style

- Python: ruff format, 4-space indent, double quotes, type hints on public APIs
- TypeScript: Prettier defaults, 2-space indent, single quotes, strict mode
- Swift: swiftlint defaults, 4-space indent
- Kotlin: ktlint defaults, 4-space indent

## Git Conventions

- Commit messages: imperative mood, <72 char subject, explain *why* in body
- Branch names: `feature/short-description`, `fix/short-description`
- Rebase workflow — no merge commits on feature branches
- Squash when merging to main unless commit history is clean and meaningful

## Communication

- Be direct. Skip preamble.
- When proposing changes, explain the tradeoff, not just the benefit.
- If something is broken, say what's broken and fix it. Don't ask permission to fix obvious bugs.
- When unsure between approaches, present the options with pros/cons and a recommendation.

## Supply Chain Security

Global package manager configs enforce a **7-day minimum release age** for all dependencies (npm, pnpm, uv, bun). This is intentional — it prevents installation of packages published less than 7 days ago as a supply chain attack mitigation.

If a package install fails because a version is "too new":
- **Do not** remove or weaken the min-release-age config.
- **Do not** bypass with `--no-verify` or equivalent flags.
- Pin the dependency to the most recent version that satisfies the age requirement.
- If no version satisfies it (brand-new package), flag it to the user — they'll decide whether to temporarily override.
- `ignore-scripts=true` is set globally for npm. If a package legitimately needs postinstall scripts, flag it rather than enabling scripts globally.

## Project Organization

- Projects live in `~/Projects/src/github.com/<org>/<repo>`
- Secrets go in `.env` files (gitignored) or direnv `.envrc`
- Never commit secrets, credentials, or API keys
