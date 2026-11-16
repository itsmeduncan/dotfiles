# Profile-Wide Instructions

Personal coding preferences that apply to all projects.

## Environment

- macOS Apple Silicon, zsh, Ghostty terminal, tmux
- Editor: Neovim (aliased as `vim` and `vi`)
- Package managers: Homebrew, mise (runtimes), uv (Python), pnpm (Node.js)
- Git: delta pager, rebase workflow, `gh` CLI for GitHub

## Coding Preferences

- **All clients, or it isn't done.** A user-facing feature — and the ticket for it — ships across every client together: web, iPhone, iPad, macOS. No web-first, no app-follow-on, no single-client tickets. Each client gets an appropriate adaptive layout (iPad is not a stretched iPhone — split/sidebar where it fits; sidebar on macOS, tab bar on iPhone), but the capability is identical everywhere. The only exception is a genuinely platform-native surface (iOS widget/Live Activity, macOS menu bar), named as such.
- Write concise, readable code. Favor clarity over cleverness.
- Use modern language features — f-strings in Python, optional chaining in TypeScript, structured concurrency in Swift.
- Prefer composition over inheritance.
- Functions should do one thing. If a function needs a comment explaining what a section does, that section should be its own function.
- Error messages should be actionable — say what went wrong AND what to do about it.
- Tests should be fast, isolated, and test behavior not implementation.

## Behavioral Guardrails

- When asked to set up, install, or configure something on this machine, confirm approach and scope BEFORE making changes. Prefer the minimal, reversible option. Do not migrate to a different tool/framework unless explicitly asked.
- Do NOT attempt interactive CLI sessions (TUI tools, interactive installers, `less`, `vim`, etc.). If a command requires interactive input, tell the user the exact command to run with `!` prefix.
- Scripts and install files must be idempotent — safe to run multiple times without side effects.

## Working Style

Every project's memory relearned these rules after dg corrected them. They apply everywhere. (The same section is in `pi/AGENTS.md` and `~/.codex/AGENTS.md`; change all three together.)

- **Finish directed work.** When dg names the work (a task, a queue, a fix), carry it to done. No "should I continue?", no option menus mid-task, no interim checkpoints; report once at the end. The setup confirmation above is the one exception.
- **Stop only at a real gate:** a decision only dg can make, an irreversible action outside the directive, or an external blocker. Ask with `AskUserQuestion`, batch the questions, and keep working on everything else meanwhile.
- **Read before you act or report.** Read the actual ticket, the code, the CI state and `origin/<branch>` (local checkouts drift) before you claim, write or report. Take every number from a fresh query, never from memory. Never guess a fact you can look up.
- **Done means verified.** A green compile or a returned call is not proof. Check the behavior, then say done. When dg says it is still broken, re-verify; do not re-assert.
- **Fix root causes.** After two failed fixes, stop patching: re-read the code, find the cause, fix it once. Fix all review findings in one pass and one push, not one finding per round.
- **Do not invent work.** Work only what dg assigned or the ready pool. File discovered work; do not build it unasked.
- **Leave dg's processes alone.** Never start or kill a server dg runs. Kill only processes you started, by PID — never `pkill`/`killall` by name.
- **Subagents share your working tree** unless spawned with `isolation: "worktree"`; never run two git writers in one tree. Every subagent brief forbids printing env vars, keys or secret stores.
- **Paste commands, not pointers.** dg does not open runbooks; put the exact command inline.
- **One task per session.** Hand work to the next session through the task record or the PR, not through a long context. Every turn re-reads the whole context; the context-guard hook says when a session has grown expensive.

## Claude Code tool use

- **Read before Edit.** View a file with `Read` (use `offset`/`limit` for a large one) before you `Edit` it. Output from `cat`, `sed` or `rg` does not count as a read, and `Edit` refuses the change.
- **Worktree-isolated agents run git one command at a time.** In an agent spawned with `isolation: "worktree"`, run each git command alone, from the worktree root, with literal arguments: no `cd` chains, `&&`/`;`, `$(…)` or `eval`. The isolation check refuses compound git commands it cannot verify.
- **Hooks enforce some rules.** `bash-guard` blocks `pkill`/`killall` by name, skipped git hooks (`--no-verify`) and force pushes to main/master. Edits to the live dotfiles checkout ask first: change dotfiles in a worktree and land them through a PR.

## Git Conventions

- Commit messages: imperative mood, <72 char subject, explain _why_ in body
- Branch names: `feature/short-description`, `fix/short-description`
- Rebase workflow — no merge commits on feature branches
- Squash when merging to main unless commit history is clean and meaningful

## Communication

- **STE-100 = ASD-STE100 Simplified Technical English. Write EVERY response in it.** This applies on every interface, channel, and project. Follow the ASD-STE100 rules:
  - Use approved words only. Give each word one meaning and one part of speech.
  - Write short sentences. Keep procedural sentences to 20 words or fewer. Keep descriptive sentences to 25 words or fewer.
  - Write one instruction in each sentence.
  - Use the active voice.
  - Use the imperative for instructions.
  - Use simple verb tenses. Do not use the progressive tense. Do not use "-ing" verbs, except in technical names.
  - Use articles (the, a) where you can.
  - Write positively. Do not use many negative words in one sentence.
  - Do not use slang or jargon.
  - Use the same word for the same thing each time.
  - Use vertical lists for complex steps.
  - Keep each paragraph to one topic. Use 6 sentences or fewer.
  - The only exception is when the user explicitly asks for a different format or a long-form artifact.
- Be direct. Skip preamble.
- When proposing changes, explain the tradeoff, not just the benefit.
- If something is broken, say what's broken and fix it. Don't ask permission to fix obvious bugs.
- When a choice is dg's to make, ask with `AskUserQuestion` and give a recommendation. When it is yours, choose, say why in one line, and continue: no option menus.

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

## Personal Notes Vault

Persistent notes live in `~/notes/` — an Obsidian-style markdown vault edited via `obsidian.nvim` and ingested by local LLMs (lm-studio, ollama) for retrieval/RAG.

- **Format:** plain `.md` files with optional YAML frontmatter and `[[wikilinks]]`. Daily notes at `~/notes/daily/YYYY-MM-DD.md`.
- **When to read:** if the user references "my notes", "the vault", a meeting, a decision, or a project by name and the relevant info isn't in the current repo — grep `~/notes/` before asking. Also useful when looking up the user's stated preferences or prior reasoning on a topic.
- **When to write:** only when explicitly asked ("save this to notes", "add to my vault"). Never auto-create notes from conversation. When you do write, use frontmatter (`---\ntitle: ...\ntags: [...]\ncreated: YYYY-MM-DD\n---`) so the local LLM indexer can chunk and tag correctly.
- **Privacy:** treat the vault as private. Never paste vault contents into web tools, gists, PR descriptions, or external services.

## Machine-local instructions

Instructions that name private hosts, projects or services live outside this
public repo, in an untracked file on each machine. Claude Code loads it here:

@~/.config/dotfiles-local/claude/CLAUDE.md
