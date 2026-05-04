---
name: deep-review
description: |
  Deep technical review of the active project. Generates full project context (architecture,
  tech stack, patterns, dependencies), then runs a multi-dimensional technical audit and
  produces actionable recommendations. Use when: "deep review", "technical audit",
  "code health deep dive", "review the whole project", "what's technically wrong with this".
argument-hint: "[--focus <area>] [--scope <directory>]"
allowed-tools: Bash, Read, Grep, Glob, Agent
context: fork
---

## Phase 1: Context Generation

Build a complete picture of the project before reviewing. This is not optional — you cannot review what you don't understand.

### 1.1 Project metadata

```bash
# Repo root and branch
git rev-parse --show-toplevel 2>/dev/null || echo "NOT_A_GIT_REPO"
git branch --show-current 2>/dev/null || echo "no-branch"

# Package manager and runtime
[ -f package.json ] && node -e "console.log(JSON.parse(require('fs').readFileSync('package.json','utf8')).name + ' v' + JSON.parse(require('fs').readFileSync('package.json','utf8')).version)" 2>/dev/null
[ -f pyproject.toml ] && head -5 pyproject.toml 2>/dev/null
[ -f Cargo.toml ] && head -5 Cargo.toml 2>/dev/null
[ -f go.mod ] && head -3 go.mod 2>/dev/null

# Dependencies
[ -f package.json ] && node -e "console.log(Object.keys(JSON.parse(require('fs').readFileSync('package.json','utf8')).dependencies||{}).join(', '))" 2>/dev/null
[ -f requirements.txt ] && wc -l < requirements.txt 2>/dev/null
```

### 1.2 Architecture map

- Glob for entry points: `src/index.ts`, `main.py`, `cmd/main.go`, `app.js`, etc.
- Read the top-level entry point and 2-3 levels deep to understand the module structure
- Identify: layers (API, service, data), patterns (MVC, hexagonal, layered), and cross-cutting concerns
- Map the dependency graph: which modules depend on which

### 1.3 Code patterns and conventions

- Read `CLAUDE.md` if present — it often contains coding standards
- Check `.editorconfig`, `tsconfig.json`, `pyproject.toml` for formatting/linting config
- Sample 3-5 representative files from different areas to identify naming conventions, error handling patterns, and architectural choices
- Note: test organization (co-located? separate dir?), logging approach, config management

### 1.4 CI/CD and tooling

```bash
# CI configs
ls .github/workflows/*.yml 2>/dev/null | head -5
[ -f Makefile ] && echo "HAS_MAKEFILE"
[ -f justfile ] && echo "HAS_JUSTFILE"

# Linting/formatting
[ -f biome.json ] || [ -f biome.jsonc ] && echo "LINT: biome"
[ -f eslint.config.* ] || [ -f .eslintrc* ] && echo "LINT: eslint"
[ -f ruff.toml ] || [ -f .ruff.toml ] && echo "LINT: ruff"
[ -f .pre-commit-config.yaml ] && echo "HAS_PRECOMMIT"

# Test runner
[ -f vitest.config.* ] && echo "TEST: vitest"
[ -f jest.config.* ] && echo "TEST: jest"
[ -f pytest.ini ] || [ -f pyproject.toml ] && echo "TEST: pytest"
```

### 1.5 Output context summary

Present a structured summary before proceeding to review:

```
## Project Context

**Stack:** <language(s) + frameworks + key dependencies>
**Architecture:** <pattern, e.g., "layered API with service layer and repository pattern">
**Size:** <total files, lines of code estimate, key modules>
**Tests:** <test framework, coverage approach, test organization>
**CI/CD:** <tools and pipeline stages detected>
**Conventions:** <naming, error handling, config patterns observed>
```

---

## Phase 2: Technical Audit

Run the following review dimensions. For each, provide findings with file paths and line numbers where applicable.

### 2.1 Architecture & Design

- **Coupling:** Are modules too tightly coupled? Circular dependencies?
- **Abstraction level:** Over-engineered (unnecessary indirection) or under-engineered (everything in one file)?
- **Separation of concerns:** Are responsibilities properly separated? (e.g., business logic mixed with HTTP handlers)
- **Scalability concerns:** Bottlenecks, N+1 queries, synchronous calls to slow services
- **Extensibility:** Would adding a new feature require touching many files?

### 2.2 Code Quality

- **Duplication:** Copy-pasted logic, similar functions with minor variations
- **Complexity:** Functions that are too long, too many parameters, deep nesting
- **Error handling:** Swallowed errors, inconsistent patterns, missing error cases
- **Type safety:** `any` types, untyped functions, missing interfaces where they'd help
- **Dead code:** Unused exports, unreachable branches, commented-out blocks

### 2.3 Security

- **Input validation:** Are user inputs validated at boundaries?
- **Auth/authz:** Missing checks, IDOR risks, privilege escalation paths
- **Secrets:** Hardcoded keys, tokens in code or config
- **Injection risks:** SQL injection, XSS, command injection, path traversal
- **Dependencies:** Known vulnerable packages (check `package-lock.json` / `requirements.txt` for red flags)

### 2.4 Performance

- **Database:** N+1 queries, missing indexes, unbounded result sets
- **APIs:** Missing pagination, large payloads, synchronous blocking calls
- **Caching:** No cache headers, missing memoization for expensive computations
- **Startup time:** Heavy initialization on every request

### 2.5 Developer Experience (DX)

- **Onboarding:** Is there a README? Can you `git clone && run` in under 5 minutes?
- **Scripts:** Are there clear commands for common tasks (dev, test, build, lint)?
- **Config sprawl:** Too many config files? Inconsistent settings across tools?
- **Debuggability:** Logging quality, observability, error messages that actually help

### 2.6 Testing

- **Coverage:** Are the right things tested? (business logic > UI wiring)
- **Test quality:** Tests that verify implementation details vs. behavior? Flaky tests?
- **Edge cases:** Boundary conditions, error paths, race conditions tested?
- **Test isolation:** Do tests share state? Can they run in parallel?

### 2.7 Dependencies & Supply Chain

- **Outdated packages:** Major versions behind? Known vulnerabilities?
- **Dependency bloat:** Unused dependencies, dev deps in production?
- **Lock files:** Present and up to date?
- **Transitive risks:** Dangerous transitive dependencies (e.g., `node-fetch` → `form-data` chain)

---

## Phase 3: Recommendations & Actions

### Severity tiers

| Tier | Meaning | Action |
|------|---------|--------|
| **Critical** | Data loss, security vuln, crash in production | Fix immediately |
| **High** | Incorrect behavior, performance killer, missing critical test | Fix this sprint |
| **Medium** | Code quality, maintainability, DX gap | Plan and schedule |
| **Low** | Style, minor cleanup, nice-to-have | Note only |

### Output format

```
## Deep Technical Review

### Summary
<2-3 sentences: overall health assessment and biggest risk areas>

### Findings by Severity

#### Critical
- `[file:line]` <description of issue> — <why it matters, what to fix>

#### High
- `[file:line]` <description> — <fix recommendation>

#### Medium
- `[file:line]` <description> — <improvement suggestion>

#### Low
- `[file:line]` <description> — <cleanup note>

### Top 3 Actions
1. [Highest impact] What to do, why it matters, estimated effort
2. [Second priority] ...
3. [Third priority] ...

### Architecture Recommendations
<structural changes that would improve the project long-term>

### Deferred (needs manual decision)
<items flagged but requiring business context or tradeoff decisions>

### Quick Wins (low effort, high impact)
<things that take <1 hour but significantly improve quality>
```

---

## Constraints

- **Cite specifics:** Every finding must include file path and line number (or function name if line is unavailable)
- **No reformatting:** Do not refactor code outside the scope of a finding
- **No speculative abstractions:** Don't recommend patterns you haven't seen evidence for in the codebase
- **When in doubt, flag not fix:** If you're uncertain about a finding's impact, note it as something to investigate rather than asserting it
- **Respect existing patterns:** If the project has a clear convention (even if not your preference), note deviations rather than recommending wholesale changes
- **Context matters:** Consider the project's stage (MVP vs. production), team size, and timeline when assessing severity
- **Omit empty tiers:** Don't include severity sections with no findings
