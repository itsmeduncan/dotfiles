---
name: sync-docs
description: Update documentation to match current code — fix stale refs, add missing sections
allowed-tools: Bash, Read, Edit, Grep, Glob, Agent
---

Verify and update documentation to match the current state of the codebase. Accepts an optional argument for a specific doc file. Otherwise scans all docs.

## Which of the two doc skills this is

`sync-docs` (this one) is the **short pass over prose docs**: does what a document
claims about the code still hold. Reach for it on a specific file, or for a quick
sweep of README and `docs/`.

`doc-sync` is the **long pass over every documentation surface**, including agent
definitions, skill frontmatter, inline comments and config-as-documentation. Reach
for it when the question is "are all our doc surfaces consistent", not "is this
file stale".

Neither is `/docs`. **`/docs` is the claude-agents toolkit auditing its own
packaging** — it reads `portable.manifest`, `GETTING-STARTED.md` and
`customer-docs/`, and writes entries for skills and agents. In any repo that is
not that toolkit, none of its inputs exist and it has nothing to say. Do not
reach for it to check a project's documentation.

## Steps

0. **List the generated docs first, and do not edit them.** A generated document
   is an output. Editing one by hand looks right, passes review, and fails CI on
   the generator's own `--check` gate, or is silently overwritten on the next run.
   Many carry no marker in the file, so find them by what a generator writes:

   ```bash
   for gen in $(grep -rhoE "(scripts/)?(build|generate)-[a-z-]+\.(py|sh|js)" \
                  .github/workflows/ Makefile justfile 2>/dev/null | sort -u); do
     [ -f "$gen" ] || gen="scripts/$(basename "$gen")"
     [ -f "$gen" ] || continue
     grep -oE '"[A-Za-z0-9_/.-]+\.(html|js|json|xml|md|css)"' "$gen"
   done | sort -u
   ```

   If one of them is genuinely stale, edit its **source** and re-run the
   generator. Say which source you edited. This matters most for files under
   `docs/`, which step 1 walks straight into.

1. **Find documentation files.** If an argument was provided, use it. Otherwise find:

   ```
   README.md, CLAUDE.md, CONTRIBUTING.md, docs/, *.md in repo root
   ```

   Minus everything step 0 listed.

2. **Parse claims about the codebase.** For each doc, extract:
   - File paths and directory references
   - Command examples and CLI usage
   - Feature descriptions and architecture claims
   - Configuration options and environment variables
   - API endpoints and function signatures

3. **Verify each claim:**
   - Do referenced files/directories exist?
   - Are commands valid? Do scripts exist?
   - Do examples match current APIs/function signatures?
   - Are configuration options still present in the code?
   - Are version numbers or dependency names current?

4. **Identify undocumented additions:**
   - New files/directories not mentioned in docs
   - New features, commands, or configuration options
   - New dependencies or tools

5. **Apply fixes:**
   - Update stale file paths and references
   - Fix outdated command examples
   - Add sections for undocumented additions
   - Remove references to deleted files/features
   - Update lists, tables, and inventories

6. **Stage changes.** Do NOT commit.

7. **Report:**
   - What was stale and corrected
   - What new content was added
   - What references were removed
   - Any claims that couldn't be verified automatically
