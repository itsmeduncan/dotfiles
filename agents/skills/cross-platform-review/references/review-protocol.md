# Cross-Platform Review Protocol

## Preamble

You are performing a comprehensive pre-launch audit of an application that ships
on more than one platform. The platforms this protocol covers are **iOS**,
**macOS** and **Android**. Some products ship a subset. Establish which ones this
repository builds before you start, and review only those.

The product is closed source. Nothing in this protocol asks whether the
repository is ready to publish, because it will not be published. Obligations the
product owes to its own dependencies are a different matter and stay in scope
(Section 7.3 and Section 11.3).

You are simultaneously embodying 12 stakeholder perspectives:

| Role                | Primary Focus                                                        |
| ------------------- | -------------------------------------------------------------------- |
| Principal Engineer  | Architecture, code quality, technical debt, scalability              |
| SDET                | Test coverage, test quality, automation, CI/CD                       |
| Product Manager     | Market positioning, user journeys, analytics, roadmap                |
| Product Owner       | Feature completeness, acceptance criteria, backlog                   |
| CEO                 | Business risk, reputation risk, launch timing, strategic alignment   |
| CMO                 | Brand consistency, messaging, store presence, growth mechanics       |
| CPO                 | Product vision coherence, UX consistency, design system              |
| CTO                 | Technical strategy, infrastructure, build systems, platform strategy |
| Security Engineer   | Threat modeling, data protection, supply chain, attack surface       |
| Licensing Counsel   | Third-party licence obligations, attribution, regulatory exposure    |
| Solutions Architect | System design, integration points, scalability, data flow            |
| Release Engineer    | Build pipelines, signing, notarization, distribution, rollback       |

**Ground rules for this review:**

- Cite specific files, functions, classes, and line numbers for every finding.
- Do not summarize or hand-wave. If you cannot find evidence, say so.
- Flag every discrepancy between platforms, no matter how small.
- Assign severity to every finding: **P0** (blocks launch), **P1** (blocks the
  next release after launch), **P2** (fix before the following minor release),
  **P3** (backlog).
- Assign effort: S (< 2 hours), M (2-8 hours), L (1-3 days), XL (3+ days).
- Derive the feature list from the repository. Do not carry in a list of features
  from another product. A canned list makes the review look thorough and report
  on things that do not exist.

## Two kinds of divergence, and they are not the same

Read this before Section 1. It decides what you look for and it is the most
common way a review of three platforms goes wrong.

**Separate codebases** diverge by drift. iOS and Android are usually two
implementations of one product in two languages. Two implementations of the same
rule disagree eventually, and nothing catches it unless a shared fixture does.
Here you compare behaviour, and you ask what holds the two in line.

**One codebase, two platforms** diverges by omission. iOS and macOS often build
from a single target, so they cannot drift on a shared rule: they share the code
that implements it. What goes wrong instead is that a capability is absent,
gated, or never exercised on the second platform, and nothing says so. Here you
look for:

- Every `#if os(...)`, `#if targetEnvironment(...)`, and `@available` gate. What
  does the platform without the code do instead? Is that stated in the UI, or is
  it silent?
- APIs that compile on both and behave differently on one. A file-protection
  class that the second platform ignores is the dangerous shape, because it
  reads as protection and is not.
- Test destinations. A suite that runs only against the simulator proves nothing
  about the second platform while appearing green.
- Platform idioms borrowed rather than met. A window that behaves like a phone
  screen is a divergence in the product, not in the code.

State which kind you are looking at in every section where it matters. A finding
that says "iOS and macOS differ" without saying which kind is not actionable.

---

## Section 1: FEATURE & FUNCTIONAL PARITY (Product Owner + Product Manager)

### 1.1 Feature Matrix

Build a complete comparison table by walking every screen, every user-facing
action, and every settings toggle on each platform:

```
| # | Feature | iOS | macOS | Android | Parity | Gap Description |
|---|---------|-----|-------|---------|--------|-----------------|
```

Enumerate from the repository, exhaustively. Read the navigation structure, the
settings screens, the URL and deep-link handlers, and the string catalogs, and
build the list from what is there.

Then check these categories, which are the ones a feature-by-feature walk
usually misses:

- Onboarding, first-run, and the empty state before any data exists
- Create, read, update, delete, list, and detail for every primary entity
- Search, filter, and sort
- Import, export, and share, in every format offered
- Offline behaviour and local persistence
- Notifications: push, local, and scheduled
- Deep links, URL schemes, and universal links
- Undo, or any other data-correction path
- Extensions: widgets, share extensions, shortcuts, app intents, quick actions
- Companion surfaces: watch, tablet layouts, car, TV
- Settings and preferences, one row at a time
- In-app feedback or diagnostics

Add, for **macOS** specifically, the surfaces a phone does not have. A Mac app
missing these is not at parity even when every screen is present:

- A menu bar with real commands, and not only the default template
- Keyboard shortcuts for the primary actions
- Multiple windows, window restore, and window sizing
- The Dock: badges, the icon menu, drag-and-drop onto the icon
- A login item or background agent, if the product promises work continues
- File-system access: open, save, drag-and-drop, and recent items
- Menu-bar-extra or status-item surfaces, if the product has one

### 1.2 Business Logic Parity

Compare every calculation, algorithm, and rule across platforms:

- The product's own domain rules, whatever they are. Read them out of the code
  rather than assuming a domain.
- Ordering, grouping, aggregation, and pagination
- Unit, date, and number conversion, including rounding behaviour
- Validation and threshold logic
- Any configurable rule or constant, and its default
- **Verification method**: identify 5 non-trivial input sets and trace them
  through each codebase manually to confirm identical outputs. Where a shared
  core or shared fixture exists, verify it is actually loaded by every suite,
  rather than assuming the coupling holds.

### 1.3 Data Model Parity

- Map every entity, field, type, default, constraint, and relationship on each
  platform.
- Flag type mismatches (Int32 against Long, a date against milliseconds).
- Compare migration strategies and version history. A migration that runs on one
  platform and not another means one client cannot open the other's data.
- Compare serialization for import, export, and any stored wire format. If the
  record is meant to be portable between clients, prove it round-trips.

### 1.4 API & Networking Parity

- List every endpoint, method, request model, and response model.
- Compare error handling, retry logic, timeouts, and caching.
- Compare certificate handling and any pinning.
- Compare offline queue and reconnect behaviour.
- Check the transport is one implementation or several. Several means the failure
  copy and the error taxonomy diverge, which users see before you do.

---

## Section 2: UI/UX POLISH PARITY (CPO + Product Manager)

### 2.1 Screen Inventory

List every screen or view on each platform. Flag any screen that exists on only
one, and say whether the absence is a decision or an omission.

### 2.2 Visual Consistency

For each shared screen, compare:

- Layout structure and component hierarchy
- Typography: family, size, weight, line height, as exact values
- Colours: extract exact values from each codebase and diff them
- Spacing, padding, and margins. Look for systematic offsets rather than
  one-off ones.
- Icons and image assets. The same set, at the same visual weight?
- Empty, loading, error, and zero-data states
- Microcopy and placeholder text
- Light and dark appearance, each given equal weight

### 2.3 Interaction Design

- Navigation model on each platform
- Gestures: swipe, pull-to-refresh, long press, pinch, edge swipe
- Pointer and keyboard, which macOS needs and a phone does not: hover states,
  right-click menus, drag-and-drop, tab order, Escape and Return behaviour,
  text-selection behaviour
- Transitions and animations, compared for how they feel rather than for how
  they are written
- Haptics, where the platform has them
- Keyboard handling: dismiss, next field, and the return-key type

### 2.4 Platform Convention Compliance

- **iOS**: the Human Interface Guidelines. Standard navigation, safe areas,
  large-title collapse, context menus, share sheets, system symbols.
- **macOS**: the Mac Human Interface Guidelines, which are a different document
  and a different product. Check the menu bar carries every command and is not a
  stub; that windows resize, restore, and support more than one; that the
  keyboard reaches everything; that the toolbar and sidebar behave like a Mac's;
  that full-screen and Stage Manager work; and that nothing on screen is a
  touch-only affordance with no pointer equivalent.
- **Android**: Material Design 3. Material components, edge-to-edge, predictive
  back, dynamic colour, adaptive icons.
- Flag any place where one platform imitates another's design language instead of
  meeting its own. An iOS layout stretched to fill a Mac window is the most
  common instance and the easiest to miss, because it builds and it runs.

### 2.5 Accessibility (WCAG 2.1 AA minimum)

- Screen readers: VoiceOver on iOS and macOS, TalkBack on Android. Every
  interactive element labelled, a logical reading order, custom components
  reachable.
- Text scaling: Dynamic Type on iOS, font scaling on Android, and the macOS text
  size setting. Does the layout survive 200%?
- Full keyboard access on macOS, which is an accessibility requirement there and
  not only an idiom.
- Colour contrast ratios, measured on the 5 most critical screens, in both
  appearances.
- Reduced motion, and Increase Contrast on Apple platforms.
- Switch Control and Switch Access.
- Semantic heading structure.

### 2.6 Localization Readiness

- Every user-facing string externalized, on every platform.
- Grep each codebase for hardcoded strings.
- Key naming consistent across platforms.
- Locale-aware formatting for numbers, dates, currency, units, and plurals.
- Right-to-left layout support.
- String length accommodation. German and Finnish run about 40% longer than
  English, and a Mac window has different constraints from a phone screen.

---

## Section 3: ARCHITECTURE REVIEW (Solutions Architect + CTO + Principal Engineer)

### 3.1 Architecture Pattern

- Describe the architecture of each app.
- Diagram the dependency graph of the major modules and layers.
- Are they consistent? If they differ, is the divergence justified and written
  down?

### 3.2 Separation of Concerns

- Is business logic fully isolated from UI?
- Is data access behind an abstraction?
- Are platform concerns encapsulated?
- Is there a shared core? If there is, check every client calls it rather than
  keeping a private reimplementation beside it. If there is not, ask whether one
  is warranted.

### 3.3 Module Structure

- How is each codebase organized?
- Are there circular dependencies?
- Are module boundaries enforced, rather than only intended?

### 3.4 Scalability & Extensibility

- How difficult is it to add a feature to each platform?
- Are extension points documented?
- Is the architecture written down, in decision records or docs?

### 3.5 Technical Debt Inventory

- List every TODO, FIXME, HACK, XXX, TEMP, and WORKAROUND with file and line.
- Identify oversized types and files (flag over 500 lines).
- Flag dead code: unused types, functions, imports, assets, and flags.
- Identify copy-pasted blocks, within a codebase and across platforms.

---

## Section 4: CODE QUALITY & MATURITY (Principal Engineer)

### 4.1 Code Health Metrics

- Cyclomatic complexity: the 10 most complex functions per platform
- Largest files by line count
- Deepest nesting
- Longest parameter lists

### 4.2 Error Handling & Resilience

- Are errors propagated or swallowed? Grep for empty catch blocks.
- Is user-facing error copy consistent, specific, and actionable on every
  platform? Copy that names the host and the number is the trust signal; a raw
  transport error is a finding.
- Does error handling distinguish cancellation from failure? A catch that
  swallows cancellation turns a normal stop into a false error, and the reverse
  turns an unreachable service into silence.
- Edge cases: no network, no permission, disk full, corrupt data, unexpected nil.
- Force unwraps and unchecked casts. List every instance.

### 4.3 Concurrency & Thread Safety

- **Apple platforms**: actor isolation, `@MainActor`, Swift concurrency, Sendable
  conformance, and data-race potential. Check isolation inherited into closures
  passed to platform callbacks, which is a common source of a runtime trap that
  compiles cleanly.
- **Android**: coroutine scope lifecycle, Dispatchers, any GlobalScope,
  main-safety of suspending functions, and Flow thread safety.
- **Both**: shared mutable state without synchronization, and races in
  persistence.

### 4.4 Memory & Performance

- **Apple platforms**: retain cycles, large allocations in loops, and hotspots
  worth profiling. On macOS also check a long-lived window and a long session,
  which a phone app never experiences.
- **Android**: context leaks, references to a destroyed Activity or Fragment, and
  large-bitmap handling.
- **Both**: performance on the product's latency-sensitive path, startup time,
  and memory footprint. Identify what that path is from the code rather than
  assuming one.

### 4.5 Dependency Injection

- The approach on each platform
- Are components injectable and testable?
- Audit every singleton and assess whether it is justified

---

## Section 5: SECURITY AUDIT (Security Engineer + CTO)

### 5.1 Threat Model

Before reading code, define the threat model:

- What sensitive data does the product hold? Read this out of the data model.
- Who are the adversaries? Consider a person with physical access to an unlocked
  device, a person with the powered-off device, someone on the same network, and
  a malicious or compromised dependency.
- What are the highest-impact scenarios?

### 5.2 Data Protection at Rest

- **iOS**: Keychain use, Data Protection classes, and file-protection attributes
  on databases and exports.
- **macOS**: this is where a single-codebase product most often has a real hole.
  iOS Data Protection is inert on macOS without the matching entitlement, so a
  product relying on it alone is unencrypted on the Mac while the code reads as
  though it is protected. Establish what actually encrypts the store on macOS.
  Full-disk encryption that the user may have turned off is not a mechanism the
  product controls.
- **Android**: the keystore, an encrypted database, and file-based encryption.
- Is any sensitive value in preferences, unencrypted, on any platform?
- Where does the key live, and what unlocks it?

### 5.3 Data Protection in Transit

- Is every connection encrypted? Check the transport-security exceptions on each
  platform.
- Certificate handling and any pinning, plus a rotation plan.
- Are credentials transmitted safely, and never in a URL or query string?

### 5.4 Secrets & Credential Hygiene

Run these searches on every codebase:

```
grep -rn "api_key\|apikey\|api-key\|secret\|password\|token\|credential\|private_key\|BEGIN RSA\|BEGIN PRIVATE" --include="*.swift" --include="*.kt" --include="*.java" --include="*.xml" --include="*.plist" --include="*.json" --include="*.gradle" --include="*.kts" --include="*.yml" --include="*.yaml" --include="*.env" --include="*.xcconfig" --include="*.rs" --include="*.ts"
```

- Check for a hardcoded key, token, or host. A hardcoded host is a finding on its
  own where the product promises it contacts only what the user configured.
- Check `.gitignore` covers every secret file, and check the ignore patterns do
  not also hide a file that is meant to be committed, such as an example
  environment file.
- Check the history: `git log --all -p -S "api_key" --source | head -50`, and the
  same for each other term. A secret removed later is still in the history.
- Check CI configuration and any committed build script.

### 5.5 Input Validation

- Injection through interpolated queries
- Path traversal in file handling
- Intent, URL scheme, and deep-link injection
- Deserialization of untrusted data, including any stored log the product reads
  back

### 5.6 Privacy Surface

- What leaves the device, and where does it go? Enumerate every outbound
  destination in the code, and compare that list against what the product claims.
- Is there analytics or telemetry? On which platform, and in which build
  flavour? A dependency added on one platform can introduce reporting the other
  platform does not have.
- Does the product respect platform tracking controls?
- Data minimization, and a way to purge old data.

### 5.7 App Hardening

- **iOS**: a stripped binary, and no debug entitlement in release.
- **macOS**: the hardened runtime enabled, the entitlement list minimal and
  justified one by one, the App Sandbox on if the product can run in it, and
  `get-task-allow` absent from the release build. Notarization is covered in 8.2.
- **Android**: R8 or ProGuard configured and tested, and `debuggable` false in
  release.
- **All**: screenshot and app-switcher treatment on sensitive screens, and
  clipboard handling.

---

## Section 6: TEST COVERAGE & QUALITY (SDET)

### 6.1 Test Inventory

Build this table from the actual test files:

```
| Test Type       | iOS | macOS | Android | Parity | Notes |
|-----------------|-----|-------|---------|--------|-------|
| Unit            |     |       |         |        |       |
| Integration     |     |       |         |        |       |
| UI / E2E        |     |       |         |        |       |
| Snapshot        |     |       |         |        |       |
| Performance     |     |       |         |        |       |
| Fuzz / Property |     |       |         |        |       |
```

Count what **runs**, not what exists. A test compiled by a target that CI never
executes is not coverage, and a suite whose only destination is a simulator
leaves macOS unproven while reporting green. State the destination for each row.

### 6.2 Coverage Analysis

- Run or estimate coverage per platform.
- Identify the 20 highest-risk untested paths, ranked by user impact.
- Focus on persistence, migration, error paths, permission flows, and whatever
  the product's core rule turns out to be.

### 6.3 Cross-Platform Test Parity

- For every test on one platform, confirm an equivalent exists on the others.
- Where a shared fixture is meant to hold platforms in line, verify every suite
  loads that same file, and verify there is a tripwire that fails when the
  fixture grows. A coupling that depends on a reviewer remembering three places
  is not a coupling.
- Check the checkers. A lint or gate has more states than the code it inspects,
  so ask what proves the gate fails on the bug it exists to catch, and stays
  quiet where its message would be false.

### 6.4 Test Quality

- Do tests assert behaviour, or only that nothing crashed?
- Flakiness indicators: sleeps, hardcoded dates, real network, device
  assumptions.
- Test data: fixtures and factories, or brittle inline values?
- Mock quality. A mock that lies produces a client that lies, and every local
  test agrees with it. Check each mock against the real implementation's wire
  behaviour.

### 6.5 CI/CD & Automation

- Compare the pipelines.
- Do tests run on every pull request and every push to the main branch?
- **Check that every path is covered by a filter, and that every filtered job is
  required.** A job that no filter triggers cannot fail, and a required check
  that skips passes. Enumerate the paths in the repository against the filters in
  CI and name anything unmatched.
- Static analysis and formatting, compared per platform.
- Automated build and distribution for each channel.
- Is there a smoke suite for a release candidate?

---

## Section 7: DEPENDENCY & SUPPLY CHAIN (Security Engineer + Licensing Counsel + CTO)

### 7.1 Dependency Inventory

Build this table for every platform:

```
| Dependency | Version | Platform | Purpose | License | Last Updated | Known CVEs | Transitive Deps |
```

Include the pin type. A dependency tracked by a branch or a floating range can
change without a visible edit, which matters most for anything security
sensitive.

### 7.2 Health Assessment

Flag dependencies that are:

- Unmaintained, with no meaningful commit in 12 months
- Subject to a known CVE
- Pulling an excessive transitive tree
- A fork of an abandoned project, or a fork at all. A fork is a standing
  obligation, so name who keeps it current and how.
- Dependent on a single maintainer

### 7.3 Third-Party Licence Obligations

These obligations apply to a closed-source product exactly as they do to an open
one. The product's own licence is out of scope; what it owes others is not.

- List every dependency licence.
- Flag any copyleft licence, and establish whether the way the product links it
  triggers its terms.
- Flag any source-available or ambiguous licence.
- Are attribution requirements met? Apache-2.0 needs a NOTICE, BSD needs its
  notice reproduced, and a bundled font under the OFL carries its own terms.
- Is there an acknowledgements screen in the app, on every platform?

### 7.4 Equivalence Check

- Are equivalent libraries used for equivalent purposes, or are there
  divergences with no reason?
- Could any dependency be removed?

---

## Section 8: BUILD, PACKAGING & RELEASE (Release Engineer + CTO)

### 8.1 Build Configuration

- Minimum OS versions, declared per platform and aligned with intent
- Dependency management compared
- Build variants and schemes: debug, staging, release, and any product flavour
- Architecture coverage. On macOS check the binary is universal, or state
  deliberately that it is not.
- Symbol files generated for crash symbolication
- Debug flags confirmed off in release
- Test credentials and development endpoints absent from release
- Is the project file generated or committed? A generated project needs its
  generator and its inputs in the build, and a committed one needs a rule that
  stops the two diverging.

### 8.2 Signing & Distribution

- **iOS**: certificate and provisioning-profile management.
- **macOS**: this is the section with the most macOS-only risk. Check the signing
  identity matches the channel, that the hardened runtime is on, that the build
  is **notarized and the ticket stapled**, and that Gatekeeper accepts it on a
  machine that has never seen it. A signed but un-notarized build fails for every
  user and passes every local test.
- **Android**: keystore management and signing configuration.
- Are signing credentials absent from the repository, and does the build refuse
  to produce an unsigned release rather than shipping one?
- Is there a provenance or checksum record for each artifact, and does the
  release job refuse to publish something it did not build?

### 8.3 Feature Flags & Remote Config

- List every flag and its state per platform.
- Are remote-config defaults consistent?
- Is anything behind a flag that must be fully on or fully removed before
  launch?

### 8.4 Store & Channel Metadata

- Bundle and application identifiers. These must match across platforms where
  the product treats them as one identity.
- Version and build numbers aligned
- Icons at every required size, for every platform slot. On Apple platforms check
  the tinted and clear variants a flat image cannot carry.
- Launch and splash treatment
- Privacy manifests, and the store data-safety declarations
- Permissions declared with a rationale string, and the shipped permission set
  pinned so a dependency cannot add one quietly
- Category, keywords, and description, consistent per channel
- **macOS channel**: Mac App Store, direct download, or both. If direct, the
  product owns its own update path, so check one exists and is signed. Check a
  package manager listing if the product claims one.

### 8.5 Rollback & Hotfix Plan

- Is there a phased rollout?
- Can the product be degraded or disabled remotely? If not, say so plainly. The
  absence of a kill switch is a finding, not an omission from the review.
- Is there a hotfix process per platform? A direct-download build cannot be
  withdrawn the way a store build can, so the plan differs by channel.

---

## Section 9: PRODUCT STRATEGY (Product Manager + CEO + CPO)

### 9.1 User Journey Validation

Walk every primary journey end to end on every platform. Derive the journeys from
the product rather than from a template. Note every friction point, dead end, and
divergence.

The journeys worth building the list around:

1. **First launch**: install, permissions, onboarding, first use, value delivered
2. **The core loop**: whatever the product exists to do, done once, fully
3. **Return visit**: open, find previous work, continue it
4. **Configuration**: change a setting, confirm it persists and takes effect
5. **Recovery**: refuse a permission, attempt the feature, grant it, resume
6. **Moving between devices**, if the product claims the record is portable
7. **macOS-specific**: quit and reopen, close the last window without quitting,
   and restart the machine. Each is a distinct state, and each breaks a product
   that assumed a phone lifecycle.

### 9.2 Degraded Experience Matrix

What happens in each situation, and is it consistent across platforms?

```
| Scenario | iOS | macOS | Android | Acceptable? |
|----------|-----|-------|---------|-------------|
| A required permission denied | | | | |
| A permission granted only while in use | | | | |
| No network | | | | |
| Network lost mid-operation | | | | |
| A configured service unreachable | | | | |
| App backgrounded mid-operation | | | | |
| App killed mid-operation | | | | |
| Device storage full | | | | |
| A very large data set | | | | |
| System clock wrong | | | | |
| OS upgrade with the app installed | | | | |
| App update over existing data | | | | |
| Data written by a newer version of the app | | | | |
| Low-power mode active | | | | |
| Screen recording active | | | | |
| Last window closed, app still running (macOS) | | | | |
| Several windows open on one record (macOS) | | | | |
| App not frontmost for a long period (macOS) | | | | |
| Machine sleeps and wakes mid-operation (macOS) | | | | |
| External display attached or removed (macOS) | | | | |
```

### 9.3 Analytics & Observability

- Is there analytics at all? If the product promises there is none, verify that
  claim per platform and per build flavour rather than accepting it.
- If there is: are event names, properties, and triggers identical across
  platforms?
- Is crash reporting configured, and is it consistent with the privacy promise?
- Are there local diagnostics good enough to explain a production failure without
  collecting anything?

### 9.4 Product Position

- Does the product communicate what it is within the first minute?
- Is its central idea legible to someone who is not an expert in the domain?
- Is there a clear next action after the core loop completes?
- Do the sharing and export paths carry the product's identity?

---

## Section 10: BRAND & GO-TO-MARKET (CMO + CEO)

### 10.1 Brand Consistency

- Name, tagline, and description consistent across every platform and all
  metadata
- Icon: one source of truth, rendering correctly in every slot on every platform
- Colour: extract the palette from each codebase and diff it
- Typography: the same hierarchy, from fonts that ship with the product rather
  than fetched at runtime
- Voice: compare all user-facing copy across platforms. One product, one voice.
  Check any copy rule the product enforces is enforced mechanically rather than
  by eye, and that the enforcement covers every platform's source.

### 10.2 Store Listing Optimization

- Each channel's listing: title, subtitle, description, keywords
- Screenshots: equivalent quality and feature coverage, correct device frames,
  and a macOS set that shows a window rather than a stretched phone screen
- Preview videos
- Ratings-prompt timing

### 10.3 Growth Mechanics

- What is shared, in what format, carrying what branding?
- Does shared content lead back to the product?
- Is there an invite or referral path?
- Social proof, if the product uses any

### 10.4 Launch Communications Readiness

- Is there a press kit or media page?
- Are the launch materials written: the announcement, the site copy, the release
  notes?
- Does the marketing site agree with what the product actually does? Check every
  capability claim against the code, and check nothing is announced ahead of its
  release train.

---

## Section 11: LEGAL & COMPLIANCE (Licensing Counsel + CEO + CPO)

### 11.1 Privacy & Data Protection

- Privacy policy: does it exist, is it reachable in the app, and is it accurate
  to what the code does?
- Terms of service: does it exist and is it reachable?
- GDPR: access, portability, and deletion
- CCPA, and any equivalent regional obligation
- COPPA, and age gating where relevant
- Consent and opt-out for anything collected, and verification that the stated
  collection matches the code on every platform

### 11.2 Regulatory

- Export control classification. Encryption in the product may require one.
- Any domain-specific disclaimer the product's own subject matter requires.
  Derive this from what the product does.
- Jurisdiction-specific rules that apply to the product's category

### 11.3 Third-Party Obligations

- Build the licence obligation matrix from Section 7.3.
- Attribution met, and NOTICE files present where required
- Source availability where a dependency's licence requires it
- An acknowledgements screen in the app on every platform

### 11.4 Trademark & Identity

- Is the product name clear for use in every market it ships to?
- Is the mark used consistently, and is it the product's own?

---

## Section 12: OUTPUT REPORT FORMAT

Produce the final report in this exact structure:

### 1. Executive Summary

- 5 sentences maximum
- Overall launch readiness grade: A (ship it) / B (minor fixes) / C (significant
  work) / D (major gaps) / F (not ready)
- A parity grade per platform pair the product ships: iOS against macOS, and
  Apple against Android. Grade them separately, because they are the two
  different kinds of divergence and a single number hides which one is bad.
- Top 3 risks

### 2. Critical Blockers (P0)

For each:

- ID: BLOCK-001, BLOCK-002, and so on
- Platform: iOS / macOS / Android / Apple / All
- Stakeholder: which role flagged it
- Description: what is wrong
- Evidence: the specific files, lines, and what you observed
- Recommendation: how to fix it
- Effort: S / M / L / XL

### 3. High-Priority Findings (P1)

The same format.

### 4. Feature Parity Matrix

The complete table from Section 1.1.

### 5. Degraded Experience Matrix

The complete table from Section 9.2.

### 6. Dependency & Licence Matrix

The complete table from Section 7.1.

### 7. Detailed Findings by Section

Every remaining finding, by section number, each with severity, platform,
stakeholder, description with code references, recommendation, and effort.

### 8. Pre-Launch Checklist

Ordered by priority. Each item:

- [ ] Task description
- Priority: P0 / P1 / P2 / P3
- Effort: S / M / L / XL
- Owner: iOS / macOS / Android / Shared core / Design / Product / Legal / Release
- Dependency: what must happen first

### 9. Post-Launch Watch List

Items that do not block launch and need watching for the first 30 days:
performance metrics, crash-rate thresholds, adoption targets, and known issues.

---

## Execution Notes

- If the codebase is too large for one pass, prioritize: Security (Section 5),
  then Feature Parity (Section 1), then Tests (Section 6), then Architecture
  (Section 3), then the rest.
- When in doubt about severity, choose the higher one. Downgrading is easier than
  missing a blocker.
- If a later section changes your understanding of an earlier one, go back and
  correct it.
- Report what you did not cover. A review that bounds itself and does not say so
  reads as complete coverage, which is worse than a stated gap.
- The report must be actionable by a small team in a two-week sprint. If the
  total effort is larger, say so in the Executive Summary.
