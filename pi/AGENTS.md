# Commonplace Memory (long-term graph memory via MCP)

`commonplace` is a two-tier knowledge graph exposed over MCP. Two tiers, **never cross them**:

- `commonplace-personal` — my own notes, projects, preferences, decisions, life.
- `commonplace-client` — confidential / client / NDA material **only** (extracts locally, never leaves the box). The personal tier may use a hosted model, so **never write confidential data to it.** When unsure, use the client tier or don't write.

**READ — search before you answer.** At the start of a task, and whenever I reference a person, project, preference, or past decision ("like we discussed", "my usual…"), search first instead of asking me to re-explain:

- `search_memory_facts(query, max_facts)` — facts/relationships between entities.
- `search_nodes(query, entity_types)` — entities, optionally filtered (e.g. `["Preference","Decision"]`).

Use specific queries and small `max_facts` — the goal is spending _fewer_ tokens than re-deriving, not dumping the graph.

**WRITE — capture durable facts, not chatter.** After learning something that matters _beyond this session_, call `add_memory` on the personal tier (or the client tier for confidential material):

- **Do:** stable preferences, decisions + rationale, people/orgs/projects and how they relate, goals, requirements, durable facts about my setup.
- **Don't:** ephemeral chatter, transient task state, secrets/credentials.
- **Check first** (a quick search) so you don't re-add an existing fact.
- **Be structured** — JSON with who/what/when/source extracts better than prose. Match the ontology (Preference, Project, Person, Decision, Goal, …); some types have typed fields (a Decision's rationale, a Risk's owner) — supply them when known.
- **Scope by project:** pass `group_id` (e.g. `group_id="acme-redesign"`) for project memory; omit for general/personal.
- **Identify yourself:** pass `agent_id="pi"` so the write is attributed.

**CITE what you used.** When a memory fact informs an answer, say so briefly ("from memory: you prefer rebase-workflow"). If you searched and found nothing, that's fine — just don't silently ignore memory.

## Working Style

Every project's memory relearned these rules after dg corrected them. They apply everywhere. (The same section is in the dotfiles repo's `claude/CLAUDE.md` and `pi/AGENTS.md`, and in `~/.codex/AGENTS.md`; change all three together.)

- **Finish directed work.** When dg names the work (a task, a queue, a fix), carry it to done. No "should I continue?", no option menus mid-task, no interim checkpoints; report once at the end. Confirming scope before setting up or installing something on this machine is the one exception.
- **Stop only at a real gate:** a decision only dg can make, an irreversible action outside the directive, or an external blocker. Ask him directly in the session, batch the questions, and keep working on everything else meanwhile.
- **Read before you act or report.** Read the actual ticket, the code, the CI state and `origin/<branch>` (local checkouts drift) before you claim, write or report. Take every number from a fresh query, never from memory. Never guess a fact you can look up.
- **Done means verified.** A green compile or a returned call is not proof. Check the behavior, then say done. When dg says it is still broken, re-verify; do not re-assert.
- **Fix root causes.** After two failed fixes, stop patching: re-read the code, find the cause, fix it once. Fix all review findings in one pass and one push, not one finding per round.
- **Do not invent work.** Work only what dg assigned or the ready pool. File discovered work; do not build it unasked.
- **Leave dg's processes alone.** Never start or kill a server dg runs. Kill only processes you started, by PID — never `pkill`/`killall` by name.
- **Subagents share your working tree** unless given their own worktree; never run two git writers in one tree. Every subagent brief forbids printing env vars, keys or secret stores.
- **Paste commands, not pointers.** dg does not open runbooks; put the exact command inline.
- **One task per session.** Hand work to the next session through the task record or the PR, not through a long context. Every turn re-reads the whole context.
