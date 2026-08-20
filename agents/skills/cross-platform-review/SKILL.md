---
name: cross-platform-review
description: "Deep cross-platform parity and launch-readiness review for apps shipping on iOS, macOS, and Android. Performs a comprehensive audit from 12 stakeholder perspectives: Principal Engineer, SDET, Product Manager, Product Owner, CEO, CMO, CPO, CTO, Security Engineer, Licensing Counsel, Solutions Architect, and Release Engineer. Use this skill whenever the user asks to compare their iOS, macOS, or Android codebases, audit app launch readiness, check feature parity across platforms, review a Mac app before release, or perform any kind of cross-platform quality gate. Also trigger when the user mentions 'parity review', 'platform audit', 'launch readiness', 'macOS readiness', or 'cross-platform comparison'. The product is treated as closed source: the review never asks for a licence, contributor documentation, or publishing readiness."
context: fork
---

# Cross-Platform Parity & Launch-Readiness Review

## Overview

This skill performs an exhaustive, multi-stakeholder audit of an application that
ships on more than one platform. It covers **iOS, macOS and Android**, and it is
the final quality gate before a public launch or a major release.

The review synthesizes 12 perspectives into a single prioritized report with
file and line references, severity ratings, and effort estimates.

**The product is closed source.** The review does not ask whether the repository
is ready to publish, and it does not grade open-source readiness. Obligations the
product owes to its own dependencies stay in scope, because a shipped app owes a
NOTICE, an attribution, and a bundled font's terms whatever its own licence is.

## When to Use

- Before a public launch or a major version release
- Before a macOS client's first release, when the Apple app already ships on iOS
- When auditing feature parity across platforms
- When a cross-functional review is needed and the team is small
- When onboarding to an unfamiliar multi-platform codebase

## The distinction this review is built on

Read this first. It is what makes a three-platform review different from a
two-platform one.

**Separate codebases diverge by drift.** iOS and Android are usually two
implementations of one product in two languages. Two implementations of the same
rule disagree eventually, and nothing catches it unless a shared fixture does.

**One codebase, two platforms diverges by omission.** iOS and macOS often build
from a single target, so they cannot drift on shared code. What goes wrong is
that a capability is absent, gated, or never exercised on the second platform,
and nothing says so: a platform gate with no stated alternative, an API that
compiles on both and behaves differently on one, a test suite whose only
destination is a simulator, or a phone layout stretched into a window.

Grade the two pairs separately. One number hides which one is bad.

## How to Run

1. Go to the repository root, or the parent directory holding each platform's
   project.
2. Orient: run `find . -maxdepth 3 -type f | head -200` and `ls -la`. Find the
   Apple project (`.xcodeproj`, `.xcworkspace`, `project.yml`, `Package.swift`),
   the Android project (`build.gradle`, `settings.gradle`), and any shared core.
3. **Establish which platforms this repository actually builds**, and which Apple
   platforms come from one target. Review only the platforms that ship, and say
   in the report which ones you covered.
4. Read the full protocol in `references/review-protocol.md`.
5. Execute it section by section, following it exactly.
6. Produce the report in the format the protocol's Output Format section
   specifies.

## Execution Strategy

This review is large. Work methodically to avoid context exhaustion:

- **Phase 1 — Inventory** (Sections 1-2): Map features, screens, and data models
  per platform. Build the parity matrix. Everything later references it.
- **Phase 2 — Depth** (Sections 3-8): Architecture, code quality, security,
  testing, dependencies, build and release. These need real source reading.
  Highest-risk areas first.
- **Phase 3 — Strategic** (Sections 9-11): Product, go-to-market, legal. These
  build on Phases 1 and 2.
- **Phase 4 — Synthesis** (Section 12): Compile the prioritized report.

Grep broadly first, then read specific files. Cite every finding with a path and
a line number. Derive every feature list from the repository rather than from a
template, because a canned list makes the review look thorough while reporting on
things that do not exist.

## Reference

- `references/review-protocol.md` — the full 12-section audit checklist with every
  stakeholder perspective. Read it before starting any review work.
- `references/cross-platform-review-prompt.md` — the same protocol condensed into
  a single prompt, for running the audit headless with
  `claude -p "$(cat references/cross-platform-review-prompt.md)"`. Keep the two
  in step: a change to one belongs in the other.
