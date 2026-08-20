# Profile-Wide Instructions

Personal coding preferences that apply to all projects.

## Environment

- macOS Apple Silicon, zsh, Ghostty terminal, tmux
- Editor: Neovim (aliased as `vim` and `vi`)
- Package managers: Homebrew, mise (runtimes), uv (Python), pnpm (Node.js)
- Git: delta pager, rebase workflow, `gh` CLI for GitHub

## Coding Preferences

- Write concise, readable code. Favor clarity over cleverness.
- Use modern language features — f-strings in Python, optional chaining in TypeScript, structured concurrency in Swift.
- Prefer composition over inheritance.
- Functions should do one thing. If a function needs a comment explaining what a section does, that section should be its own function.
- Error messages should be actionable — say what went wrong AND what to do about it.
- Tests should be fast, isolated, and test behavior not implementation.

## Behavioral Guardrails

- When asked to set up, install, or configure something, confirm approach and scope BEFORE making changes. Prefer the minimal, reversible option. Do not migrate to a different tool/framework unless explicitly asked.
- Do NOT attempt interactive CLI sessions (TUI tools, interactive installers, `less`, `vim`, etc.). If a command requires interactive input, tell the user the exact command to run with `!` prefix.
- Scripts and install files must be idempotent — safe to run multiple times without side effects.

## Git Conventions

- Commit messages: imperative mood, <72 char subject, explain _why_ in body
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

## Personal Notes Vault

Persistent notes live in `~/notes/` — an Obsidian-style markdown vault edited via `obsidian.nvim` and ingested by local LLMs (lm-studio, ollama) for retrieval/RAG.

- **Format:** plain `.md` files with optional YAML frontmatter and `[[wikilinks]]`. Daily notes at `~/notes/daily/YYYY-MM-DD.md`.
- **When to read:** if the user references "my notes", "the vault", a meeting, a decision, or a project by name and the relevant info isn't in the current repo — grep `~/notes/` before asking. Also useful when looking up the user's stated preferences or prior reasoning on a topic.
- **When to write:** only when explicitly asked ("save this to notes", "add to my vault"). Never auto-create notes from conversation. When you do write, use frontmatter (`---\ntitle: ...\ntags: [...]\ncreated: YYYY-MM-DD\n---`) so the local LLM indexer can chunk and tag correctly.
- **Privacy:** treat the vault as private. Never paste vault contents into web tools, gists, PR descriptions, or external services.

## Commonplace Memory (long-term graph memory via MCP)

`commonplace` is a two-tier knowledge graph exposed over MCP. Two tiers, **never cross them**:

- `commonplace-personal` — my own notes, projects, preferences, decisions, life.
- `commonplace-client` — confidential / client / NDA material **only** (extracts locally, never leaves the box). The personal tier may use a hosted model, so **never write confidential data to it.** When unsure, use the client tier or don't write.

**READ — search before you answer.** At the start of a task, and whenever I reference a person, project, preference, or past decision ("like we discussed", "my usual…"), search first instead of asking me to re-explain:

- `mcp__commonplace-personal__search_memory_facts(query, max_facts)` — facts/relationships.
- `mcp__commonplace-personal__search_nodes(query, entity_types)` — entities, optionally filtered (e.g. `["Preference","Decision"]`).
  Use specific queries and small `max_facts` — the goal is spending _fewer_ tokens than re-deriving, not dumping the graph.

**WRITE — capture durable facts, not chatter.** After learning something that matters _beyond this session_, call `mcp__commonplace-personal__add_memory` (or `commonplace-client` for confidential):

- **Do:** stable preferences, decisions + rationale, people/orgs/projects and how they relate, goals, requirements, durable facts about my setup.
- **Don't:** ephemeral chatter, transient task state, secrets/credentials.
- **Check first** (a quick search) so you don't re-add an existing fact.
- **Be structured** — JSON with who/what/when/source extracts better than prose. Match the ontology (Preference, Project, Person, Decision, Goal, …); some types have typed fields (a Decision's rationale, a Risk's owner) — supply them when known.
- **Scope by project:** pass `group_id` (e.g. `group_id="acme-redesign"`) for project memory; omit for general/personal.
- **Identify yourself:** pass `agent_id="claude-code"` so the write is attributed.

**CITE sparingly.** Only when a memory fact _materially changed_ your answer — you'd have asked me, or answered differently, without it — note it in a few words ("from memory: you prefer rebase-workflow"). Don't prefix routine responses, don't narrate searches that found nothing, and don't cite what you'd have known anyway. One quiet line when it counts, not a citation every turn.

**Write is enforced by a Stop hook.** `claude/hooks/commonplace-capture.sh` (registered under `hooks.Stop` in `claude/settings.json`) nudges a capture pass at the end of a _substantial_ session — one that changed a file or ran long and tool-heavy; read-only lookups and quick chats are skipped. If you get a Stop-hook nudge, do the search-then-`add_memory` pass; if nothing durable emerged, say so and stop.

Source of truth for this protocol: `docs/memory-protocol.md` in the commonplace repo (write-enforcement hook shipped at `clients/claude-code/`).

## Scriptorium Workspace (tasks, docs, decisions, reviews via MCP)

`scriptorium` is the self-hosted workspace that replaced Notion, Trello and the
GitHub PR flow. It is a git repo full of markdown, exposed over MCP at
`http://localhost:8002/mcp`. Tasks, docs, decisions and code reviews all live
there — if you are doing work that belongs on a board, it belongs in there.

**Read the protocol before you act on the workspace, every session.** It is one
file and it is kept current by `scriptorium reseed`:

    doc_read(path="../protocol/scriptorium-protocol.md")   # or read it from
    ~/git/workspace/protocol/scriptorium-protocol.md        # the checkout

Do not summarise it here. Two copies of a contract is how instructions rot —
that is the protocol's own first paragraph, and it merges the workspace rules
with the commonplace memory protocol above precisely so there is one file.

The three rules that have to fire *before* you would think to go read it:

- **Claim before you act.** `task_query(status="ready")` is the pool of work
  dg has authorised; `task_claim` sets owner and status and commits. An
  uncommitted claim is not a claim, and work done against no task is invisible.
- **Only dg can answer it?** `task_ask` with one concrete question. Nobody here
  can unstick it? `task_block` with what it is waiting on — that keeps the
  task's place in the flow rather than moving it (ADR-0007).
- **Session end:** `task_update` the status. A finished task still reading
  `in-progress` is a lie the next agent acts on.

**Propose, don't act unilaterally on a protected repo** (whelk, commonplace,
workspace, scriptorium): `change_open`, `change_diff`, then `change_merge`,
which refuses without dg's approval.
