---
name: doc-sync
description: |
  Keep all documentation surfaces up to date across the project. Scans README, CLAUDE.md,
  agent definitions, skills, docs/, CONTRIBUTING, CHANGELOG, and inline code comments.
  Fixes stale references, adds missing docs for new features, aligns agent/skill configs
  with actual capabilities. Use when: "sync docs", "update documentation", "docs are stale",
  "keep docs current".
argument-hint: "[--focus <surface>] [--dry-run]"
allowed-tools: Bash, Read, Grep, Glob, Edit, Write, Agent
context: fork
---

## Surface Inventory

Scan for all documentation surfaces in the project. Each surface has different doc types and verification rules.

### 1. README.md
- Project overview, setup instructions, usage examples
- Feature list, architecture diagram references
- CLI commands, configuration options

### 2. CLAUDE.md (project-level)
- Coding conventions and style rules
- Skill routing table
- Health stack configuration
- Project structure description

### 3. Agent Definitions (`claude/agents/*.md`)
- Tool permissions (Read, Write, Bash, etc.)
- Effort level settings
- Descriptions of what each agent does

### 4. Skills (`claude/skills/*/SKILL.md`)
- YAML frontmatter: name, description, argument-hint, allowed-tools, context
- Preamble scripts (bash commands at top)
- Step-by-step workflow instructions
- Voice/tone guidelines

### 5. docs/ Directory (if present)
- API documentation, guides, tutorials
- Architecture decisions (ADRs)
- Deployment/runbook docs

### 6. CONTRIBUTING.md, CHANGELOG.md
- Contribution guidelines, PR process
- Version history, release notes

### 7. Inline Code Comments (JSDoc, docstrings)
- Function/class descriptions
- Parameter/return type documentation
- Example usage in comments

### 8. Config-as-Documentation
- `tsconfig.json`, `pyproject.toml`, `.eslintrc` — options that users configure
- Environment variable documentation (`.env.example`, `README` config section)

---

## Phase 1: Scan & Catalog

### 1.1 Discover all doc surfaces

```bash
# Core docs
ls README.md CLAUDE.md CONTRIBUTING.md CHANGELOG.md 2>/dev/null

# Agent definitions
ls claude/agents/*.md 2>/dev/null || echo "NO_AGENTS_DIR"

# Skills
find claude/skills -name SKILL.md 2>/dev/null || echo "NO_SKILLS_DIR"

# docs/ directory
ls docs/*.md 2>/dev/null || echo "NO_DOCS_DIR"

# Env/config docs
ls .env.example env.example 2>/dev/null || echo "NO_ENV_EXAMPLE"

# Inline docs (sample key files)
find src -name "*.ts" -o -name "*.tsx" -o -name "*.py" 2>/dev/null | head -10
```

### 1.2 Build a doc inventory table

Present the discovered surfaces:

```
## Doc Surface Inventory

| Surface | Files Found | Last Modified | Status |
|---------|-------------|---------------|--------|
| README.md | 1 | 2026-04-15 | needs review |
| CLAUDE.md | 1 | 2026-04-28 | needs review |
| Agents (5) | 5 files | mixed dates | needs review |
| Skills (12) | 12 SKILL.md | mixed dates | needs review |
| docs/ | 3 files | 2026-03-10 | stale? |
| .env.example | 1 | 2026-04-01 | needs review |
```

---

## Phase 2: Verification & Sync

For each surface, run the appropriate verification checks.

### 2.1 README.md Verification

**Stale references:**
```bash
# Check file/directory references in README
grep -nE '(\.\/|src/|lib/|config/)' README.md 2>/dev/null | while read line; do
  filepath=$(echo "$line" | sed 's/.*README.md://' | grep -oE '[a-zA-Z0-9_./\-]+' | head -1)
  [ -n "$filepath" ] && [ ! -e "$filepath" ] && echo "STALE_REF: README.md:$line -> $filepath (not found)"
done

# Check CLI commands exist
grep -nE '^\s*`\$?([a-z]+)' README.md 2>/dev/null | while read line; do
  cmd=$(echo "$line" | grep -oE '[a-z]+' | head -1)
  command -v "$cmd" >/dev/null 2>&1 || echo "MISSING_CMD: README.md references '$cmd' which is not installed"
done

# Check npm scripts referenced in docs
grep -oE 'npm run [a-z-]+' README.md 2>/dev/null | while read ref; do
  script=$(echo "$ref" | awk '{print $3}')
  node -e "const p=JSON.parse(require('fs').readFileSync('package.json','utf8')); if(!p.scripts[$script]) process.exit(1)" 2>/dev/null || echo "STALE_SCRIPT: README.md references 'npm run $script' not in package.json"
done
```

**Missing docs for new features:**
- Compare recent git commits (last 20) against README content
- New files/directories not mentioned in README → flag for addition

### 2.2 CLAUDE.md Verification

**Stale skill routing:**
```bash
# Check if skills listed in CLAUDE.md still exist as SKILL.md files
grep -oE '/[a-z-]+' CLAUDE.md 2>/dev/null | while read skill; do
  skill_name=$(echo "$skill" | tr -d '/')
  [ ! -f "claude/skills/$skill_name/SKILL.md" ] && echo "STALE_ROUTING: CLAUDE.md references /$skill_name but skill directory doesn't exist"
done

# Check if new skills are missing from routing table
find claude/skills -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read dir; do
  skill_name=$(basename "$dir")
  grep -q "/$skill_name" CLAUDE.md 2>/dev/null || echo "MISSING_ROUTING: Skill '$skill_name' exists but not in CLAUDE.md routing table"
done
```

**Stale health stack:**
- Verify each tool in `## Health Stack` still exists and is configured correctly

**Stale agent descriptions:**
- Cross-reference `claude/agents/*.md` tool permissions with actual skill/tool availability

### 2.3 Agent Definitions Verification

For each `claude/agents/*.md`:
- Verify allowed-tools match available tools (Bash, Read, Write, Edit, Grep, Glob, Agent, AskUserQuestion)
- Check that tool names match what Claude Code actually supports
- Verify effort levels are appropriate for the agent's scope

### 2.4 Skills Verification

For each `claude/skills/*/SKILL.md`:
- **Frontmatter consistency:** Check that `allowed-tools` only lists tools the skill actually uses in its workflow
- **Trigger alignment:** Do `triggers` match what the skill description says it does?
- **Argument hint accuracy:** Does `argument-hint` match the actual accepted arguments in the workflow?
- **Preamble scripts:** Do bash commands in preamble still work? (check for deprecated binaries, changed paths)
- **Orphan skills:** Skills with no triggers or empty descriptions

### 2.5 docs/ Directory Verification

- Check for broken internal links (`[text](./other-doc.md)`)
- Verify code examples match current API
- Check for outdated version numbers in dependency references
- Identify docs that reference deleted features

### 2.6 Inline Code Comments Verification

Sample key public APIs and check:
- JSDoc/docstring parameter names match actual function signatures
- Return type annotations are accurate
- Examples in comments still work (or at least reference valid functions)

```bash
# TypeScript JSDoc examples
grep -rn '@param\|@returns\|@example' src/ --include='*.ts' --include='*.tsx' 2>/dev/null | head -20

# Python docstrings
grep -rn '"""' src/ --include='*.py' 2>/dev/null | head -20
```

### 2.7 Environment Variables & Config Docs

- Compare `.env.example` (or equivalent) with actual code that reads env vars
- Flag env vars used in code but missing from docs
- Flag env vars in docs but not used in code (stale)

```bash
# Find env var usage in code
grep -rn 'process\.env\|os\.environ\|getenv' src/ --include='*.ts' --include='*.py' 2>/dev/null | \
  grep -oE '(process\.env|os\.environ|getenv)\(["'"'"']([A-Z_]+)["'"'"']\)' | \
  grep -oE '[A-Z_]+' | sort -u > /tmp/env_vars_in_code.txt

# Find env vars in docs
grep -oE '[A-Z_]{3,}=' README.md .env.example 2>/dev/null | \
  grep -oE '[A-Z_]+' | sort -u > /tmp/env_vars_in_docs.txt

# Compare
diff /tmp/env_vars_in_code.txt /tmp/env_vars_in_docs.txt || true
```

---

## Phase 3: Apply Fixes

### Priority order for fixes:

1. **Broken references** (files/dirs that don't exist) — fix immediately
2. **Missing env var docs** — add to `.env.example` and relevant doc
3. **Stale CLI commands/scripts** — update or remove
4. **Missing skill routing entries** — add to CLAUDE.md
5. **Agent tool permission mismatches** — align with actual capabilities
6. **Stale inline docs** — update parameter/return types

### Fix rules:

- **README.md:** Update stale references, add missing feature descriptions, fix broken commands
- **CLAUDE.md:** Add missing skill routing entries, update health stack, fix stale agent descriptions
- **Agent definitions:** Align tool permissions with available tools
- **Skills:** Fix frontmatter inconsistencies, update stale preamble scripts
- **docs/:** Fix broken links, update code examples
- **Inline comments:** Update parameter names and return types to match signatures

**Do NOT:**
- Rewrite doc style or tone (preserve existing voice)
- Add major new sections without user confirmation
- Change project structure documentation that would require reorganization

---

## Phase 4: Report

Present a structured report:

```
## Doc Sync Report

### Summary
<1-2 sentences on overall doc health and biggest gaps>

### Stale Content (Fixed)
| File | Line/Section | What was stale | Fix applied |
|------|-------------|----------------|-------------|
| README.md:12 | Setup section | Referenced `bin/setup` which was renamed to `install.sh` | Updated path |
| CLAUDE.md:45 | Skill routing | Referenced `/old-skill` which no longer exists | Removed entry |

### Missing Content (Added)
| Surface | What was missing | Where added |
|---------|-----------------|-------------|
| .env.example | `DATABASE_URL` used in code but not documented | Added to env example + README config section |
| Skills | `deep-review` skill not in routing table | Added to CLAUDE.md skill routing |

### Stale Content (Flagged — needs manual review)
| File | Issue | Why it needs human input |
|------|-------|-------------------------|
| docs/api.md | References v2 endpoints that may still be live | Need to confirm deprecation status |
| README.md | Architecture diagram references old repo structure | Diagram needs visual update, not just text fix |

### Stats
- Surfaces scanned: X
- Stale references fixed: Y
- Missing docs added: Z
- Items flagged for review: W
```

---

## Dry Run Mode

When `--dry-run` is passed as an argument:
- Perform all scanning and verification
- Present the full report
- Do NOT apply any fixes — just list what would change

---

## Constraints

- **Preserve voice:** Don't rewrite doc style, only fix accuracy
- **Cite sources:** Every finding must reference the specific file and line/section
- **Don't over-document:** Only document public APIs and user-facing features, not internal implementation details
- **Respect existing structure:** Don't reorganize docs; fix content within the current structure
- **Batch related fixes:** Group changes by file to minimize commit churn
