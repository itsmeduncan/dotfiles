---
name: audit
description: Explore and catalog a codebase area — files, abstractions, patterns, and issues
argument-hint: "<directory, pattern, or concept>"
allowed-tools: Bash, Read, Grep, Glob, Agent
context: fork
---

Thoroughly audit a codebase area. Argument is a directory path, file pattern, or concept (e.g., "authentication", "API endpoints").

## Steps

1. **Resolve the target.**
   - Directory path → recursively find all files
   - File pattern (e.g., `*.py`) → glob for matches
   - Concept (e.g., "authentication") → grep across the codebase, then read matches

2. **Read all matching files.** Use parallel reads where possible. For large directories, prioritize entry points and public APIs first.

3. **Build a structured inventory:**
   - Files found (grouped by type/purpose)
   - Key abstractions: classes, functions, routes, models, types
   - Dependencies between files (imports, calls)
   - Patterns observed (naming conventions, architectural patterns, shared utilities)

4. **Identify issues:**
   - Inconsistencies (naming, patterns, error handling)
   - Dead code (unused exports, unreachable branches)
   - Missing tests
   - Outdated patterns (deprecated APIs, old conventions)
   - Security concerns

5. **Output a markdown summary** organized by:
   - **Overview:** what this area does, how it fits into the project
   - **File inventory:** table of files with purpose
   - **Key abstractions:** the important types/functions/routes
   - **Dependency graph:** how files relate
   - **Findings:** issues and recommendations, sorted by severity

This is a read-only skill. Do NOT modify any files.
