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

Every project's memory relearned these rules after dg corrected them. They apply everywhere.

- **Finish directed work.** When dg names the work (a task, a queue, a fix), carry it to done. No "should I continue?", no option menus mid-task, no interim checkpoints; report once at the end. The setup confirmation above is the one exception.
- **Stop only at a real gate:** a decision only dg can make, an irreversible action outside the directive, or an external blocker. Ask with `AskUserQuestion`, batch the questions, and keep working on everything else meanwhile.
- **Read before you act or report.** Read the actual ticket, the code, the CI state and `origin/<branch>` (local checkouts drift) before you claim, write or report. Take every number from a fresh query, never from memory. Never guess a fact you can look up.
- **Done means verified.** A green compile or a returned call is not proof. Check the behavior, then say done. When dg says it is still broken, re-verify; do not re-assert.
- **Fix root causes.** After two failed fixes, stop patching: re-read the code, find the cause, fix it once. Fix all review findings in one pass and one push, not one finding per round.
- **Do not invent work.** Work only what dg assigned or the ready pool. File discovered work; do not build it unasked.
- **Leave dg's processes alone.** Never start or kill a server dg runs. Kill only processes you started, by PID — never `pkill`/`killall` by name.
- **Subagents share your working tree** unless spawned with `isolation: "worktree"`; never run two git writers in one tree. Every subagent brief forbids printing env vars, keys or secret stores.
- **Paste commands, not pointers.** dg does not open runbooks; put the exact command inline.

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
- **Stay quiet about it.** The capture is plumbing. Don't narrate what you searched or list what you saved — report the whole pass in **one terse line, max**: `memory: saved 2 — deploy prefs, tier split`, or `memory: nothing durable`. Never more.

**CITE sparingly.** Only when a memory fact _materially changed_ your answer — you'd have asked me, or answered differently, without it — note it in a few words ("from memory: you prefer rebase-workflow"). Don't prefix routine responses, don't narrate searches that found nothing, and don't cite what you'd have known anyway. One quiet line when it counts, not a citation every turn.

**Write is enforced by a Stop hook.** `claude/hooks/commonplace-capture.sh` (registered under `hooks.Stop` in `claude/settings.json`) nudges a capture pass at the end of a _substantial_ session — one that changed a file or ran long and tool-heavy; read-only lookups and quick chats are skipped. If you get a Stop-hook nudge, do the search-then-`add_memory` pass; if nothing durable emerged, say so and stop.

Source of truth for this protocol: `docs/memory-protocol.md` in the commonplace repo (write-enforcement hook shipped at `clients/claude-code/`).

## Scriptorium Workspace (tasks, docs, decisions, reviews via MCP)

`scriptorium` is the self-hosted workspace that replaced Notion, Trello and the
GitHub PR flow. It is a git repo full of markdown, exposed over MCP at
`https://scriptorium.tail1cf291.ts.net:8443/mcp` (tailnet-only, TLS via tailscale serve; LXC 104 on Proxmox). Tasks, docs, decisions and code reviews all live
there — if you are doing work that belongs on a board, it belongs in there.

**Read the protocol before you act on the workspace, every session.** It is one
page and it is kept current by `scriptorium reseed`:

    mcp__scriptorium__doc_read({"slug": "scriptorium-protocol"})

Do not summarise it here. Two copies of a contract is how instructions rot —
that is the protocol's own first paragraph, and it merges the workspace rules
with the commonplace memory protocol above precisely so there is one file.

The three rules that have to fire _before_ you would think to go read it:

- **Claim before you act.** `task_query({"status": ["ready"]})` is the pool of work
  dg has authorised; `task_claim` sets owner and status and commits. An
  uncommitted claim is not a claim, and work done against no task is invisible.
- **Only dg can answer it?** In an interactive session, ask him now with
  `AskUserQuestion` (he has said "stop filing questions and ASK ME"). In a
  dispatched run with nobody present, `task_ask` with one concrete question. Nobody here
  can unstick it? `task_block` with what it is waiting on — that keeps the
  task's place in the flow rather than moving it (ADR-0007).
- **Session end:** `task_update` the status. A finished task still reading
  `in-progress` is a lie the next agent acts on.

Call shapes, from ~900 refused calls in one month:

- The tools are deferred. Load a tool's schema with `ToolSearch`
  (`select:mcp__scriptorium__<tool>,...`, batched) before its first call. A
  call sent from a guessed schema is refused.
- Every mutation needs `idempotency_key`: a fresh UUID per intended change,
  reused only to retry that change.
- List filters such as `status` and `priority` take arrays, never a string.
- Free text goes in `text` (`task_append`), `question` (`task_ask`) and `why`
  (`task_block`), not `body`, `note` or `reason`. Pages and projects take
  `slug`; changes take `id`. `change_open` requires `repo`, `project`,
  `branch` and `title`, with task links in `closes`/`relates`, never in the body.
- The decision search tool is `decision_search` (the protocol page says
  `decisions_search`, which does not exist).

**Propose, don't act unilaterally on a protected repo** (whelk, commonplace,
workspace, scriptorium): `change_open`, `change_diff`, then `change_merge`,
which refuses without dg's approval.
