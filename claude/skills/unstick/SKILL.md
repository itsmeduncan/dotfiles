---
name: unstick
description: Diagnose why a dev environment won't start — check deps, ports, configs, runtimes
allowed-tools: Bash, Read, Grep, Glob
---

Diagnose and fix a broken dev environment. Accepts an optional argument describing the symptom. Otherwise runs broad diagnostics.

## Steps

1. **Detect the project stack** from config files in the current directory:
   - `pyproject.toml` / `requirements.txt` → Python
   - `package.json` → TypeScript/Node
   - `*.xcodeproj` / `Package.swift` → iOS/Swift
   - `build.gradle*` / `settings.gradle*` → Android/Kotlin
   - `docker-compose.yml` / `compose.yml` → Docker
   - `Makefile` / `justfile` → check for run/start targets

2. **Check universal issues:**
   - Git state: dirty working tree, merge conflicts, detached HEAD
   - `.env` / `.envrc` presence (does direnv need `direnv allow`?)
   - Runtime version: does `.python-version` / `.node-version` / `.tool-versions` match installed?

3. **Stack-specific checks:**
   - **Python:** virtualenv exists (`uv venv`), `uv pip check` passes, correct Python version
   - **TypeScript:** `node_modules` exists, `pnpm install` needed, correct Node version, port conflicts (`lsof -i :<port>`)
   - **iOS:** Xcode CLI tools installed (`xcode-select -p`), `pod install` needed, derived data issues
   - **Android:** `ANDROID_HOME` set, SDK path valid, Gradle daemon running, emulator state
   - **Docker:** `docker compose ps` — are containers running? Check logs for crashed containers

4. **Auto-fix what's safe:**
   - `direnv allow` if `.envrc` exists but not allowed
   - `pnpm install` / `uv sync` / `pod install` if lockfile is newer than installed deps
   - Kill zombie processes on commonly used ports (3000, 5000, 8000, 8080)
   - `mise install` if runtime versions are missing

5. **Report:**
   - Pass/fail for each check
   - What was auto-fixed
   - Specific commands for issues that need manual intervention
