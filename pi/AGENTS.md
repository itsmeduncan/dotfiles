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
