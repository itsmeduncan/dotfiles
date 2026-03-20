---
name: sync-docs
description: Update documentation to match current code — fix stale refs, add missing sections
allowed-tools: Bash, Read, Edit, Grep, Glob, Agent
---

Verify and update documentation to match the current state of the codebase. Accepts an optional argument for a specific doc file. Otherwise scans all docs.

## Steps

1. **Find documentation files.** If an argument was provided, use it. Otherwise find:
   ```
   README.md, CLAUDE.md, CONTRIBUTING.md, docs/, *.md in repo root
   ```

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
