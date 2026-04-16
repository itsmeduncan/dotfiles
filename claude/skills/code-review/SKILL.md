---
name: code-review
description: Review code for bugs, security issues, and quality — either a diff (branch/file/range) or a full holistic codebase cleanup. Trigger when the user asks to "review", "check", "audit", or "clean up" code. With no argument performs a full codebase quality pass. With a branch/file/range argument reviews only that diff.
argument-hint: "[branch | file | diff range | --full]"
allowed-tools: Bash, Read, Grep, Glob, Agent
context: fork
---

Two modes depending on the argument:

- **Diff review** (argument is a branch, file path, or git range): review only what changed
- **Full codebase review** (no argument, or `--full`): run all 8 quality agents in parallel

---

## Mode 1: Diff Review

### 1. Get the diff

- Branch name → `git diff main...<branch>`
- File path → `git diff HEAD -- <path>`
- Diff range (e.g. `HEAD~3`) → `git diff <range>`
- Staged only → `git diff --cached`

Capture the full diff. If it exceeds ~500 lines, summarize by file first, then drill into the highest-risk files.

### 2. Understand context

For each changed file, read enough surrounding context to understand what invariants the change relies on and whether it has knock-on effects. Use `grep` to find callers of modified functions; use `glob` to find related test files.

### 3. Review categories

**Bugs and correctness**

- Logic errors, off-by-one, wrong operator precedence
- Null/undefined dereferences, unhandled None/nil
- Race conditions in async code (await ordering, shared mutable state)
- Incorrect error handling — swallowed exceptions, wrong error type caught
- Missing edge cases (empty list, zero, negative, boundary values)

**Security**

- Injection risks: SQL, shell, HTML/XSS, path traversal
- Auth bypasses: missing checks, IDOR, privilege escalation
- Secrets in code, logs, or error messages
- SSRF, open redirect, unsafe deserialization
- Cryptographic misuse (weak algorithms, hardcoded keys, broken IV reuse)

**Data integrity**

- Missing DB transactions around multi-step writes
- TOCTOU races (read-then-write without atomic guard)
- Cascading deletes or updates that could lose data

**Code quality**

- Duplicated logic that should be extracted
- Functions doing more than one thing
- Unnecessary state, premature abstraction
- Dead code, unused variables, unreachable branches
- Comments that describe WHAT instead of WHY

**Tests**

- Missing test for the changed behavior
- Tests that pass trivially or are over-mocked

### 4. Severity tiers

| Tier         | Meaning                                                    | Action          |
| ------------ | ---------------------------------------------------------- | --------------- |
| **Critical** | Data loss, auth bypass, security vuln, crash               | Fix immediately |
| **High**     | Incorrect behavior, race condition, missing error handling | Fix now         |
| **Medium**   | Code quality, missing tests, performance concern           | Fix or defer    |
| **Low**      | Style, naming, minor cleanup                               | Note only       |

Fix Critical and High findings directly. Do not fix Medium or Low unless trivial.

### 5. Output

```
## Code Review

### Summary
<1-3 sentence overview of what changed and overall risk>

### Critical / High / Medium / Low
- [file:line] <finding> — <fix applied / action needed>

### Tests
<pass / gaps / recommendations>

### Verdict
APPROVE | REQUEST CHANGES | NEEDS DISCUSSION
```

Omit tiers with no findings. If the change is clean, say so directly.

---

## Mode 2: Full Codebase Review

Run all 8 agents **in parallel** in a single message. Each agent does its own deep research, writes a critical assessment, and implements all high-confidence fixes.

### Launch all 8 agents simultaneously:

**Agent 1 — Deduplication & DRY**
Research: find duplicated logic, copy-pasted blocks, and near-identical functions across the codebase. Use grep for repeated patterns, read the files, assess complexity impact. Implement consolidations where the abstraction reduces complexity without adding indirection for its own sake. Do not DRY things that are coincidentally similar but semantically different.

**Agent 2 — Type consolidation**
Research: find all type/interface definitions (TypeScript: `interface`, `type`, `enum`; Python: `TypedDict`, `dataclass`, `Pydantic`; etc). Identify duplicates, overlapping shapes, and types that should be shared across packages. Consolidate into shared locations. Update all imports. Do not over-abstract — only merge types that are genuinely the same concept.

**Agent 3 — Dead code removal**
Research: use available tools to find unused code:

- TypeScript/JS: run `npx knip` or `npx ts-prune`; also grep for exports with no imports
- Python: run `vulture` if available; grep for functions/classes with no callers
- Any language: check for unreachable branches, unused variables, unused imports

Before deleting anything, grep for every reference. Remove only what is confirmed dead. Do not remove public API surface that might be used externally unless the repo is a private application.

**Agent 4 — Circular dependency resolution**
Research: map the dependency graph.

- TypeScript/JS: run `npx madge --circular --extensions ts,tsx,js,jsx .`
- Python: analyze imports manually or use `pydeps` if available

For each cycle found: read the involved files, understand why the cycle exists, and resolve it by extracting shared types/utilities to a new module, inverting the dependency, or using dependency injection. Document the approach used.

**Agent 5 — Weak type elimination**
Research: find all weak types:

- TypeScript: `any`, `unknown` (when cast away immediately), `object`, `{}`, untyped function params
- Python: `Any`, missing annotations on public functions, bare `dict`/`list` without generics

For each weak type: research what the actual type should be by reading how the value is used, checking related packages/libraries for their type definitions, and tracing the data flow. Replace with specific types. Run the type checker after changes to confirm no regressions. Do not replace `unknown` with a specific type if the value genuinely is unknown at that boundary — instead, add a proper type guard.

**Agent 6 — Try/catch cleanup**
Research: find all try/catch blocks (and language equivalents: Python `try/except`, Go `if err != nil` patterns, etc).

For each one, assess:

- **Keep**: handles genuinely unknown/unsanitized external input (network, user input, file system, third-party APIs), provides meaningful recovery, or is at a system boundary
- **Remove**: hides errors silently, has an empty catch, logs-and-continues for internal logic errors, wraps code that cannot realistically throw, or exists defensively "just in case"

When removing: let the error propagate naturally. If the caller needs to handle it, add it to the function signature. Do not replace removed try/catch with new defensive patterns.

**Agent 7 — Legacy & fallback code removal**
Research: find deprecated, legacy, and fallback code:

- Feature flags that are always-on or always-off
- `TODO`, `FIXME`, `HACK`, `DEPRECATED` comments
- Old API versions running alongside new ones
- `if (legacyMode)` / `if (v2Enabled)` / `if (featureFlag)` style conditionals
- Fallback paths that exist only because a migration is "in progress"
- Commented-out code blocks

For each: verify the new path is used everywhere, remove the old path, and clean up any dead conditionals. Make all code paths singular and direct.

**Agent 8 — AI slop & comment cleanup**
Research: find:

- Stub implementations (functions that just `return null` / `pass` / `throw new Error("not implemented")`)
- Larp code (code that looks like it does something but doesn't — fake logging, no-op handlers, placeholder business logic)
- Comments that narrate the change ("previously we used X, now we use Y"), describe in-motion work ("TODO: replace this"), or explain what the code obviously does
- Excessive inline documentation for trivial logic
- Boilerplate comment blocks that add no information (copyright headers in private repos, auto-generated "this class is responsible for..." comments)

For stubs: if the stub is referenced by real code, either implement it or raise a clear `NotImplementedError` with a descriptive message. If it's unreferenced, remove it (covered by Agent 3).

For comments: remove comments that explain WHAT. Keep comments that explain WHY (non-obvious constraints, workarounds, subtle invariants). Rewrite any comment that describes in-motion work into a clear present-tense description of what the code does and why, or remove it if no explanation is needed.

### After all agents complete

Aggregate findings into a final report:

```
## Full Codebase Review

### Agent Results
- Agent 1 (DRY): <summary of changes / findings>
- Agent 2 (Types): <summary>
- Agent 3 (Dead code): <summary>
- Agent 4 (Circular deps): <summary>
- Agent 5 (Weak types): <summary>
- Agent 6 (Try/catch): <summary>
- Agent 7 (Legacy): <summary>
- Agent 8 (Slop): <summary>

### Files Changed
<list of modified files>

### Deferred (needs manual decision)
<anything agents flagged but didn't fix, with reasoning>

### Next Steps
<any follow-up work recommended>
```

## Constraints (both modes)

- Always cite file path and line number for every finding
- Do NOT reformat or refactor code outside the scope of the finding
- Do NOT add comments explaining what the code does
- Do NOT introduce new abstractions speculatively
- When in doubt, flag rather than fix
