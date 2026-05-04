---
name: cross-platform-review
description: "Deep cross-platform parity and launch-readiness review for iOS and Android mobile apps. Performs a comprehensive audit from 12 stakeholder perspectives: Principal Engineer, SDET, Product Manager, Product Owner, CEO, CMO, CPO, CTO, Security Engineer, Licensing Counsel, Solutions Architect, and Release Engineer. Use this skill whenever the user asks to compare iOS and Android codebases, audit mobile app launch readiness, check feature parity across platforms, review code before open-sourcing a mobile app, or perform any kind of cross-platform quality gate. Also trigger when the user mentions 'parity review', 'platform audit', 'launch readiness', 'open source prep', or 'cross-platform comparison' for mobile apps."
context: fork
---

# Cross-Platform Parity & Launch-Readiness Review

## Overview

This skill performs an exhaustive, multi-stakeholder audit of paired iOS and Android codebases. It is designed to be the final quality gate before open-sourcing and publicly launching a mobile application.

The review synthesizes 12 distinct perspectives into a single prioritized report with specific file/line references, severity ratings, and effort estimates.

## When to Use

- Before open-sourcing a mobile app with iOS and Android targets
- Before a public launch or major version release
- When auditing feature parity across platforms
- When a cross-functional review is needed but the team is small
- When onboarding to an unfamiliar dual-platform codebase

## How to Run

1. Navigate to the repository root (or the parent directory containing both iOS and Android projects).
2. Orient yourself: run `find . -maxdepth 3 -type f | head -200` and `ls -la` to understand the repo structure. Identify where the iOS project (`.xcodeproj`, `.xcworkspace`, `Package.swift`) and Android project (`build.gradle`, `settings.gradle`) live.
3. Read the full review protocol in `references/review-protocol.md`.
4. Execute the review section by section, following the protocol exactly.
5. Produce the output report in the format specified in the protocol's Output Format section.

## Execution Strategy

This review is large. Work methodically to avoid context exhaustion:

- **Phase 1 — Inventory** (Sections 1-2): Map features, screens, and data models. Build the parity matrix. This is the foundation everything else references.
- **Phase 2 — Depth** (Sections 3-7): Architecture, code quality, security, testing. These require reading actual source files. Focus on the highest-risk areas first.
- **Phase 3 — Strategic** (Sections 8-12): Product, go-to-market, licensing, executive concerns. These build on findings from Phases 1-2.
- **Phase 4 — Synthesis** (Section 13): Compile the final report with prioritized findings.

For each section, grep/search broadly first, then drill into specific files. Cite every finding with file path and line number.

## Reference

The complete review protocol is in:
- `references/review-protocol.md` — The full 13-section audit checklist with all stakeholder perspectives. Read this before starting any review work.
