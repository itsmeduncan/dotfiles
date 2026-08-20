# CLAUDE CODE: Cross-Platform Parity & Launch-Readiness Audit

# Usage: claude -p "$(cat cross-platform-review-prompt.md)"

# Run from the repository root containing every platform target.

---

You are performing the final quality gate before a public launch of an
application that ships on more than one platform. The platforms this audit covers
are **iOS**, **macOS** and **Android**. Establish which of them this repository
builds before you start, and review only those.

**The product is closed source.** Do not review whether the repository is ready to
publish, do not ask for a licence, contributor documentation, or an external
contributor path, and do not grade open-source readiness. Obligations the product
owes to its own dependencies stay in scope and are Section 7.3 and Section 11.3.

You are simultaneously embodying **12 stakeholder perspectives**:

1. **Principal Engineer** — Architecture, code quality, technical debt, scalability
2. **SDET** — Test coverage, test quality, automation, CI/CD
3. **Product Manager** — Market positioning, user journeys, analytics, growth
4. **Product Owner** — Feature completeness, acceptance criteria, edge cases
5. **CEO** — Business risk, reputation risk, launch timing, strategic alignment
6. **CMO** — Brand consistency, store presence, growth mechanics, launch comms
7. **CPO** — Product vision, UX consistency, design system, accessibility
8. **CTO** — Technical strategy, infrastructure, build systems, platform strategy
9. **Security Engineer** — Threat model, data protection, supply chain, attack surface
10. **Licensing Counsel** — Third-party licence obligations, attribution, regulatory exposure
11. **Solutions Architect** — System design, integration points, data flow, module boundaries
12. **Release Engineer** — Build pipelines, signing, notarization, distribution, rollback

## Ground Rules

- **Cite specific files, functions, classes, and line numbers** for every finding.
  No hand-waving.
- Flag every discrepancy between platforms, no matter how small.
- Severity: **P0** (blocks launch), **P1** (blocks the next release), **P2** (fix
  before the following minor release), **P3** (backlog).
- Effort: **S** (< 2hr), **M** (2-8hr), **L** (1-3 days), **XL** (3+ days).
- If you cannot find evidence for something, say so explicitly.
- **Derive every feature list from this repository.** Do not carry in features
  from another product. A canned list makes the audit look thorough and report on
  things that do not exist.

## Two kinds of divergence

This decides what you look for. Get it right before Section 1.

- **Separate codebases** (usually Apple against Android) diverge by **drift**.
  Two implementations of one rule disagree eventually, and nothing catches it
  unless a shared fixture does. Compare behaviour, and ask what holds them in
  line.
- **One codebase, two platforms** (usually iOS against macOS, from a single
  target) diverges by **omission**. They cannot drift on shared code; instead a
  capability is absent, gated, or never exercised on the second platform. Look
  for every `#if os(...)` and `@available` gate and ask what the other platform
  does; for APIs that compile on both and behave differently on one; for test
  destinations that never include the second platform; and for platform idioms
  borrowed rather than met.

Say which kind every cross-platform finding is. "iOS and macOS differ" without
that is not actionable.

## Execution Strategy

- **Phase 1 — Inventory**: Orient, map features, build the parity matrix.
- **Phase 2 — Depth**: Architecture, code quality, security, tests.
- **Phase 3 — Strategic**: Product, go-to-market, legal.
- **Phase 4 — Synthesis**: Compile the report.

Start with `find . -maxdepth 3 -type f | head -300` and `ls -laR | head -200`.
Identify each platform's project: Apple (`.xcodeproj`, `.xcworkspace`,
`project.yml`, `Package.swift`), Android (`build.gradle`, `settings.gradle`), and
any shared core. Note which Apple platforms one target builds. Then proceed
section by section.

---

## SECTION 1: FEATURE & FUNCTIONAL PARITY

_Perspective: Product Owner + Product Manager_

### 1.1 Feature Matrix

Walk every screen, action, and settings toggle on each platform:

| #   | Feature | iOS | macOS | Android | Parity? | Gap |
| --- | ------- | --- | ----- | ------- | ------- | --- |

Build the list from the navigation structure, the settings screens, the deep-link
handlers, and the string catalogs. Then check the categories a screen walk
misses: onboarding and the pre-data empty state; full CRUD, list and detail per
entity; search, filter, sort; import, export, share in every format; offline and
local persistence; notifications (push, local, scheduled); deep links and URL
schemes; undo and data correction; extensions (widgets, share, shortcuts, app
intents); companion surfaces; every settings row; in-app feedback.

**For macOS, add the surfaces a phone has no equivalent for.** A Mac app missing
these is not at parity even with every screen present: a menu bar carrying real
commands rather than the default template; keyboard shortcuts for the primary
actions; multiple windows, window restore and sizing; the Dock (badge, icon menu,
drag-and-drop); a login item or background agent if the product promises work
continues; file-system access (open, save, drag-and-drop, recents); any
status-item surface.

### 1.2 Business Logic Parity

Compare every calculation and rule across platforms. Read the domain rules out of
the code rather than assuming a domain. Cover ordering, grouping, aggregation,
pagination, unit and date conversion including rounding, validation, thresholds,
and configurable constants with their defaults. Identify 5 non-trivial input sets
and trace them through each codebase. Where a shared core or fixture is meant to
hold platforms in line, verify every suite actually loads it.

### 1.3 Data Model Parity

Map every entity, field, type, default, constraint, and relationship per
platform. Flag type mismatches. Compare migrations, and note that a migration
present on one platform only means one client cannot open the other's data.
Compare serialization for import, export, and any stored wire format; if the
record is meant to be portable, prove it round-trips.

### 1.4 API & Networking Parity

Every endpoint, method, request and response model. Compare error handling,
retry, timeouts, caching, certificate handling, and reconnect behaviour. Check
whether the transport is one implementation or several; several means the error
taxonomy and failure copy diverge.

---

## SECTION 2: UI/UX POLISH PARITY

_Perspective: CPO + Product Manager_

### 2.1 Screen Inventory

Every screen per platform. Flag any that exists on one only, and say whether the
absence is a decision or an omission.

### 2.2 Visual Consistency

Per shared screen: layout hierarchy, typography (exact family/size/weight/line
height), colours (extract exact values and diff), spacing and padding (look for
systematic offsets), icons and assets, empty/loading/error/zero-data states,
microcopy, and both light and dark appearance with equal weight.

### 2.3 Interaction Design

Navigation model; gestures (swipe, pull-to-refresh, long press, pinch, edge
swipe); **pointer and keyboard**, which macOS requires — hover states,
right-click menus, drag-and-drop, tab order, Escape and Return, text selection;
transitions compared for feel; haptics; keyboard handling.

### 2.4 Platform Convention Compliance

- **iOS**: HIG — standard navigation, safe areas, large-title collapse, context
  menus, share sheets, system symbols
- **macOS**: the _Mac_ HIG, a different document and a different product. Menu
  bar carries every command and is not a stub; windows resize, restore, and
  support more than one; the keyboard reaches everything; toolbar and sidebar
  behave like a Mac's; full-screen and Stage Manager work; nothing is a
  touch-only affordance with no pointer equivalent.
- **Android**: MD3 — Material components, edge-to-edge, predictive back, dynamic
  colour, adaptive icons

Flag any platform imitating another's design language instead of meeting its own.
**An iOS layout stretched to fill a Mac window is the most common instance and
the easiest to miss, because it builds and it runs.**

### 2.5 Accessibility (WCAG 2.1 AA)

VoiceOver on iOS and macOS, TalkBack on Android. Text scaling at 200% on every
platform. **Full keyboard access on macOS**, which is a requirement there and not
only an idiom. Contrast ratios on the 5 most critical screens, in both
appearances. Reduced motion and Increase Contrast. Switch Control and Switch
Access. Semantic heading structure.

### 2.6 Localization Readiness

Externalized strings per platform. Hardcoded-string grep. Key naming
consistency. Locale-aware numbers, dates, units, plurals. RTL. String length
accommodation, noting a Mac window constrains differently from a phone screen.

---

## SECTION 3: ARCHITECTURE

_Perspective: Solutions Architect + CTO + Principal Engineer_

### 3.1 Pattern

Describe each app's architecture. Diagram the dependency graph. Assess
consistency, and whether any divergence is justified and written down.

### 3.2 Separation of Concerns

Business logic isolated from UI? Data access behind an abstraction? Platform
concerns encapsulated? **Is there a shared core, and does every client call it
rather than keeping a private reimplementation beside it?** If there is none, ask
whether one is warranted.

### 3.3 Module Structure

Feature modules against layer modules against monolith. Circular dependencies?
Are boundaries enforced rather than only intended?

### 3.4 Scalability

Cost of adding a feature per platform. Extension points documented? Decision
records present?

### 3.5 Technical Debt Inventory

- `grep -rn "TODO\|FIXME\|HACK\|XXX\|TEMP\|WORKAROUND"` across every language in
  the repository — list every hit with context
- Oversized types and files (flag over 500 lines)
- Dead code: unused types, functions, imports, assets, flags
- Copy-pasted blocks within a codebase and across platforms

---

## SECTION 4: CODE QUALITY

_Perspective: Principal Engineer_

### 4.1 Metrics

Top 10 complexity hotspots per platform. Largest files. Deepest nesting. Longest
parameter lists.

### 4.2 Error Handling

Empty catch blocks. Is user-facing error copy consistent, specific and actionable
per platform — naming the host and the number rather than exposing a raw
transport error? **Does error handling distinguish cancellation from failure?** A
catch swallowing cancellation turns a normal stop into a false error; the reverse
turns an unreachable service into silence. Edge cases: no network, no permission,
disk full, corrupt data, unexpected nil. Every force unwrap and unchecked cast.

### 4.3 Concurrency

- **Apple**: actor isolation, `@MainActor`, async/await, Sendable, data-race
  potential. **Check isolation inherited into closures passed to platform
  callbacks** — a common runtime trap that compiles cleanly.
- **Android**: coroutine scope lifecycle, Dispatchers, GlobalScope, main-safety,
  Flow thread safety
- **Both**: shared mutable state without synchronization; races in persistence

### 4.4 Memory & Performance

- **Apple**: retain cycles, large allocations in loops. On macOS also a long-lived
  window and a long session, which a phone app never experiences.
- **Android**: context leaks, references to a destroyed Activity or Fragment,
  large bitmaps
- **Both**: the latency-sensitive path (identify it from the code), startup time,
  memory footprint

### 4.5 Dependency Injection

Approach per platform. Injectability and testability. Singleton audit with
justification.

---

## SECTION 5: SECURITY

_Perspective: Security Engineer + CTO_

### 5.1 Threat Model

What sensitive data, read out of the data model? Adversaries: physical access to
an unlocked device, the powered-off device, someone on the same network, a
compromised dependency. Highest-impact scenarios?

### 5.2 Data at Rest

- **iOS**: Keychain, Data Protection classes, file protection on databases and
  exports
- **macOS**: where a single-codebase product most often has a real hole. **iOS
  Data Protection is inert on macOS without the matching entitlement**, so a
  product relying on it alone is unencrypted on the Mac while the code reads as
  protected. Establish what actually encrypts the store there. Full-disk
  encryption the user may have turned off is not a mechanism the product
  controls.
- **Android**: keystore, encrypted database, file-based encryption
- Any sensitive value in preferences unencrypted, on any platform? Where does the
  key live and what unlocks it?

### 5.3 Data in Transit

Every connection encrypted? Transport-security exceptions per platform.
Certificate handling and rotation. Credentials never in a URL or query string.

### 5.4 Secrets Hygiene

```bash
grep -rn "api_key\|apikey\|secret\|password\|token\|credential\|private_key\|BEGIN RSA\|BEGIN PRIVATE" --include="*.swift" --include="*.kt" --include="*.java" --include="*.xml" --include="*.plist" --include="*.json" --include="*.gradle" --include="*.kts" --include="*.yml" --include="*.yaml" --include="*.env" --include="*.xcconfig" --include="*.rs" --include="*.ts"
```

Hardcoded key, token, or host. **A hardcoded host is a finding on its own where
the product promises it contacts only what the user configured.** Check
`.gitignore` covers every secret file _and_ does not also hide a file meant to be
committed, such as an example environment file. Search history:
`git log --all -p -S "api_key" --source | head -50`, and the same per term.
Check CI configuration and committed build scripts.

### 5.5 Input Validation

Interpolated queries. Path traversal. Intent, URL scheme and deep-link
injection. Untrusted deserialization, including any stored log read back.

### 5.6 Privacy Surface

What leaves the device and where to — enumerate every outbound destination in the
code and compare it against what the product claims. **Is there analytics or
telemetry, on which platform and in which build flavour?** A dependency added on
one platform can introduce reporting the other lacks. Platform tracking
controls. Data minimization and a purge path.

### 5.7 Hardening

- **iOS**: stripped binary, no debug entitlement in release
- **macOS**: hardened runtime on, entitlements minimal and justified one by one,
  App Sandbox on if the product can run in it, `get-task-allow` absent from
  release
- **Android**: R8/ProGuard configured and tested, `debuggable` false in release
- **All**: screenshot and app-switcher treatment on sensitive screens, clipboard
  handling

---

## SECTION 6: TESTING

_Perspective: SDET_

### 6.1 Inventory

| Type          | iOS | macOS | Android | Parity? | Notes |
| ------------- | --- | ----- | ------- | ------- | ----- |
| Unit          |     |       |         |         |       |
| Integration   |     |       |         |         |       |
| UI/E2E        |     |       |         |         |       |
| Snapshot      |     |       |         |         |       |
| Performance   |     |       |         |         |       |
| Fuzz/Property |     |       |         |         |       |

**Count what runs, not what exists.** A test compiled by a target CI never
executes is not coverage, and a suite whose only destination is a simulator
leaves macOS unproven while reporting green. State the destination per row.

### 6.2 Coverage

Run or estimate per platform. Top 20 highest-risk untested paths by user impact:
persistence, migration, error paths, permission flows, and the product's core
rule.

### 6.3 Cross-Platform Parity

Every test on one platform has an equivalent on the others. **Where a shared
fixture holds platforms in line, verify every suite loads that same file and that
a tripwire fails when the fixture grows** — a coupling depending on a reviewer
remembering three places is not a coupling. **Check the checkers**: a lint or gate
has more states than the code it inspects, so ask what proves the gate fails on
the bug it exists to catch and stays quiet where its message would be false.

### 6.4 Quality

Meaningful assertions or smoke tests? Flakiness (sleeps, hardcoded dates, real
network, device assumptions)? Test data management? **Mock quality — a mock that
lies produces a client that lies, and every local test agrees with it.** Check
each mock against the real implementation's wire behaviour.

### 6.5 CI/CD

Pipeline comparison. Tests on every PR and every push to main? **Check every path
is covered by a filter and every filtered job is required** — a job no filter
triggers cannot fail, and a required check that skips passes. Enumerate the
repository's paths against the filters and name anything unmatched. Static
analysis and formatting per platform. Automated distribution per channel.
Release-candidate smoke suite?

---

## SECTION 7: DEPENDENCIES & SUPPLY CHAIN

_Perspective: Security Engineer + Licensing Counsel + CTO_

### 7.1 Inventory

| Dependency | Version | Platform | Purpose | License | Last Updated | CVEs | Transitive Count |
| ---------- | ------- | -------- | ------- | ------- | ------------ | ---- | ---------------- |

Include the **pin type**. A dependency tracked by a branch or a floating range
can change with no visible edit, which matters most for anything security
sensitive.

### 7.2 Health

Flag: unmaintained (12+ months), known CVEs, excessive transitive tree, a fork
(name who keeps it current and how), single-maintainer risk.

### 7.3 Third-Party Licence Obligations

**These apply to a closed-source product exactly as to an open one.** The
product's own licence is out of scope; what it owes others is not.

Every dependency licence listed. Flag copyleft and establish whether the linking
model triggers its terms. Flag source-available and ambiguous licences.
Attribution met — Apache-2.0 needs a NOTICE, BSD needs its notice reproduced, a
bundled font under the OFL carries its own terms. Acknowledgements screen present
in the app on every platform?

### 7.4 Equivalence

Same library for the same purpose across platforms? Divergences with no reason?
Anything removable?

---

## SECTION 8: BUILD & RELEASE

_Perspective: Release Engineer + CTO_

### 8.1 Configuration

Min OS versions per platform, aligned with intent. Dependency managers compared.
Variants, schemes and flavours. **Architecture coverage — on macOS the binary is
universal, or deliberately stated not to be.** Symbol files for symbolication.
Debug flags off in release. Test credentials and development endpoints absent.
**Is the project file generated or committed?** A generated project needs its
generator and inputs in the build; a committed one needs a rule stopping the two
diverging.

### 8.2 Signing & Distribution

- **iOS**: certificates and provisioning profiles
- **macOS**: the most macOS-only risk in the audit. Signing identity matches the
  channel; hardened runtime on; **the build is notarized and the ticket stapled**;
  Gatekeeper accepts it on a machine that has never seen it. **A signed but
  un-notarized build fails for every user and passes every local test.**
- **Android**: keystore and signing configuration
- Signing credentials absent from the repository, and does the build **refuse to
  produce an unsigned release** rather than shipping one?
- A provenance or checksum record per artifact, and does the release job refuse to
  publish something it did not build?

### 8.3 Feature Flags

Every flag and its state per platform. Remote-config defaults consistent?
Anything that must be fully on or fully removed before launch?

### 8.4 Store & Channel Metadata

Bundle and application identifiers — matching across platforms where the product
treats them as one identity. Versions aligned. Icons at every size for every
platform slot, including the tinted and clear Apple variants a flat image cannot
carry. Launch treatment. Privacy manifests and store data-safety declarations.
Permissions with rationale strings, and **the shipped permission set pinned so a
dependency cannot add one quietly**. Category, keywords, description per channel.
**macOS channel**: Mac App Store, direct download, or both — if direct, the
product owns its own update path, so check one exists and is signed, plus any
package-manager listing it claims.

### 8.5 Rollback

Phased rollout? **Can the product be degraded or disabled remotely? If not, say so
plainly — the absence of a kill switch is a finding, not an omission from the
audit.** Hotfix process per platform, noting a direct-download build cannot be
withdrawn the way a store build can.

---

## SECTION 9: PRODUCT STRATEGY

_Perspective: Product Manager + CEO + CPO_

### 9.1 User Journeys

End to end on every platform. Derive the journeys from the product, not a
template. Note every friction point, dead end, and divergence:

1. First launch → permissions → onboarding → first use → value delivered
2. The core loop, whatever the product exists to do, done once and fully
3. Return visit → find previous work → continue it
4. Configuration → change a setting → confirm it persists and takes effect
5. Recovery → refuse a permission → attempt the feature → grant → resume
6. Moving between devices, if the product claims the record is portable
7. **macOS**: quit and reopen; close the last window without quitting; restart the
   machine. Three distinct states, each of which breaks a product that assumed a
   phone lifecycle.

### 9.2 Degraded Experience Matrix

| Scenario                                       | iOS | macOS | Android | Acceptable? |
| ---------------------------------------------- | --- | ----- | ------- | ----------- |
| A required permission denied                   |     |       |         |             |
| Permission granted only while in use           |     |       |         |             |
| No network                                     |     |       |         |             |
| Network lost mid-operation                     |     |       |         |             |
| A configured service unreachable               |     |       |         |             |
| App backgrounded mid-operation                 |     |       |         |             |
| App killed mid-operation                       |     |       |         |             |
| Storage full                                   |     |       |         |             |
| A very large data set                          |     |       |         |             |
| Clock wrong                                    |     |       |         |             |
| OS upgrade with the app installed              |     |       |         |             |
| App update over existing data                  |     |       |         |             |
| Data written by a newer app version            |     |       |         |             |
| Low-power mode                                 |     |       |         |             |
| Screen recording active                        |     |       |         |             |
| Last window closed, app still running (macOS)  |     |       |         |             |
| Several windows on one record (macOS)          |     |       |         |             |
| Not frontmost for a long period (macOS)        |     |       |         |             |
| Machine sleeps and wakes mid-operation (macOS) |     |       |         |             |
| External display attached or removed (macOS)   |     |       |         |             |

### 9.3 Analytics & Observability

**Is there analytics at all?** If the product promises none, verify that claim per
platform and per build flavour rather than accepting it. If there is: event
names, properties and triggers identical across platforms? Crash reporting
configured, and consistent with the privacy promise? Local diagnostics good
enough to explain a production failure without collecting anything?

### 9.4 Product Position

Does the product say what it is within the first minute? Is its central idea
legible to a non-expert? A clear next action after the core loop? Do sharing and
export carry the product's identity?

---

## SECTION 10: BRAND & GO-TO-MARKET

_Perspective: CMO + CEO_

### 10.1 Brand Consistency

Name, tagline, description consistent across every platform and all metadata.
Icon from one source of truth, rendering correctly in every slot. Colour palette
extracted per codebase and diffed. Typography hierarchy, from fonts shipped with
the product rather than fetched at runtime. **Voice: one product, one voice —
and check any copy rule the product enforces is enforced mechanically rather than
by eye, across every platform's source.**

### 10.2 Store Listings

Per channel: title, subtitle, description, keywords. Screenshots of equivalent
quality and coverage, correct frames, and **a macOS set showing a window rather
than a stretched phone screen**. Preview videos. Ratings-prompt timing.

### 10.3 Growth Mechanics

What is shared, in what format, with what branding? Does it lead back to the
product? Invite or referral path? Social proof?

### 10.4 Launch Communications Readiness

Press kit or media page? Announcement, site copy, and release notes written?
**Does the marketing site agree with what the product actually does?** Check every
capability claim against the code, and check nothing is announced ahead of its
release train.

---

## SECTION 11: LEGAL & COMPLIANCE

_Perspective: Licensing Counsel + CEO + CPO_

### 11.1 Privacy & Data Protection

Privacy policy: exists, reachable in-app, and accurate to what the code does?
Terms of service? GDPR access, portability, deletion. CCPA and regional
equivalents. COPPA and age gating where relevant. Consent and opt-out for
anything collected, verified against the code on every platform.

### 11.2 Regulatory

Export control classification, which encryption may require. Any disclaimer the
product's own subject matter requires, derived from what it does.
Jurisdiction-specific rules for its category.

### 11.3 Third-Party Obligations

The licence obligation matrix from 7.3. Attribution met and NOTICE files present.
Source availability where a licence requires it. Acknowledgements screen in the
app on every platform.

### 11.4 Trademark & Identity

Is the name clear for use in every market it ships to? Is the mark used
consistently, and is it the product's own?

---

## SECTION 12: OUTPUT REPORT

Produce the final report in **exactly this structure**:

### 1. Executive Summary (5 sentences max)

- Overall launch readiness: A / B / C / D / F
- **A parity grade per platform pair the product ships** — iOS against macOS, and
  Apple against Android. Grade them separately: they are the two different kinds
  of divergence, and one number hides which is bad.
- Top 3 risks

### 2. Critical Blockers (P0)

Each: ID (BLOCK-NNN) | Platform (iOS / macOS / Android / Apple / All) |
Stakeholder | Description | Evidence (file:line) | Fix | Effort

### 3. High Priority (P1)

The same format.

### 4. Feature Parity Matrix (Section 1.1 table)

### 5. Degraded Experience Matrix (Section 9.2 table)

### 6. Dependency & Licence Matrix (Section 7.1 table)

### 7. Detailed Findings (P2/P3)

By section. Each: Severity | Platform | Stakeholder | Description with code refs |
Fix | Effort

### 8. Pre-Launch Checklist

Ordered by priority:

- [ ] Task
- Priority: P0-P3
- Effort: S/M/L/XL
- Owner: iOS / macOS / Android / Shared core / Design / Product / Legal / Release
- Depends on: (if any)

### 9. Post-Launch Watch List

30-day monitoring: performance metrics, crash-rate thresholds, adoption targets,
known issues.

### 10. Coverage of This Review

What you did **not** cover, and why. A review that bounds itself without saying so
reads as complete coverage, which is worse than a stated gap.

---

**Begin the review now. Start with Phase 1 (repo orientation, which platforms are
built, and the feature inventory), then proceed through all sections.**
