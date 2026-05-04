# CLAUDE CODE: Cross-Platform Parity & Launch-Readiness Audit
# Usage: claude -p "$(cat cross-platform-review-prompt.md)"
# Run from the repository root containing both iOS and Android projects.

---

You are performing the final quality gate before open-sourcing and publicly launching a mobile application with iOS and Android targets. You are simultaneously embodying **12 stakeholder perspectives**:

1. **Principal Engineer** — Architecture, code quality, technical debt, scalability
2. **SDET** — Test coverage, test quality, automation, CI/CD
3. **Product Manager** — Market positioning, user journeys, analytics, growth
4. **Product Owner** — Feature completeness, acceptance criteria, edge cases
5. **CEO** — Business risk, reputation risk, launch timing, strategic alignment
6. **CMO** — Brand consistency, app store presence, viral mechanics, launch comms
7. **CPO** — Product vision, UX consistency, design system, accessibility
8. **CTO** — Technical strategy, infrastructure, open-source governance, build systems
9. **Security Engineer** — Threat model, data protection, supply chain, pen-test surface
10. **Licensing Counsel** — OSS license compliance, IP exposure, contributor agreements
11. **Solutions Architect** — System design, integration points, data flow, module boundaries
12. **Release Engineer** — Build pipelines, signing, distribution, rollback, feature flags

## Ground Rules

- **Cite specific files, functions, classes, and line numbers** for every finding. No hand-waving.
- Flag every discrepancy between platforms, no matter how small.
- Assign severity: **P0** (blocks launch), **P1** (blocks open-source), **P2** (fix before v1.1), **P3** (backlog).
- Assign effort: **S** (< 2hr), **M** (2-8hr), **L** (1-3 days), **XL** (3+ days).
- If you cannot find evidence for something, say so explicitly.

## Execution Strategy

Work in phases to manage context:
- **Phase 1 — Inventory**: Orient, map features, build parity matrix.
- **Phase 2 — Depth**: Architecture, code quality, security, tests.
- **Phase 3 — Strategic**: Product, go-to-market, licensing, governance.
- **Phase 4 — Synthesis**: Compile report.

Start by running `find . -maxdepth 3 -type f | head -300` and `ls -laR | head -200` to understand the repo structure. Identify where the iOS project (.xcodeproj, .xcworkspace, Package.swift) and Android project (build.gradle, settings.gradle) live. Then proceed section by section.

---

## SECTION 1: FEATURE & FUNCTIONAL PARITY
*Perspective: Product Owner + Product Manager*

### 1.1 Feature Matrix
Walk every screen, every user-facing action, every settings toggle on each platform. Build this table:

| # | Feature | iOS | Android | Parity? | Gap |
|---|---------|-----|---------|---------|-----|

Include at minimum: core measurement/capture flow, primary calculations and statistical methods, session CRUD and detail views, data visualization (charts, histograms, distributions, maps), location/GPS and map integration, camera/sensor integration, settings and preferences, onboarding and first-run experience, share/export (CSV, PDF, image, deep link), offline mode and data persistence, notifications, deep links and URL schemes, search and filtering, undo/data correction, home screen widgets, watch/wearable companion, voice assistant integration, in-app feedback mechanism.

### 1.2 Business Logic Parity
Compare every calculation and algorithm line-by-line. Identify 5 non-trivial input sets and manually trace them through both codebases to verify identical outputs. Focus on: percentile calculations (V85), aggregation, outlier detection, unit conversions with rounding behavior, thresholds, validation rules, configurable constants.

### 1.3 Data Model Parity
Map every entity, field, type, default, constraint, and relationship across Core Data/SwiftData (iOS) and Room/SQLite (Android). Flag type mismatches (Int32 vs Long, Date vs timestamp millis). Compare migration strategies. Compare import/export serialization.

### 1.4 API & Networking Parity
List every endpoint, HTTP method, request model, response model. Compare error handling, retry logic, timeouts, caching. Compare certificate pinning. Compare offline queue/sync behavior.

---

## SECTION 2: UI/UX POLISH PARITY
*Perspective: CPO + Product Manager*

### 2.1 Screen Inventory
List every screen on each platform. Flag any that exists on only one.

### 2.2 Visual Consistency
Per shared screen: layout hierarchy, typography (exact font/size/weight/line-height values), colors (extract exact hex values and diff), spacing/padding/margins, icons and assets, empty/loading/error/zero-data states, microcopy.

### 2.3 Interaction Design
Navigation patterns, gesture support (swipe-to-delete, pull-to-refresh, long-press, pinch, edge swipe), transitions and animations, haptic feedback, keyboard handling.

### 2.4 Platform Convention Compliance
- **iOS**: HIG — SF Symbols, standard navigation, safe area, large titles, context menus, share sheets
- **Android**: MD3 — Material components, edge-to-edge, predictive back, dynamic color, adaptive icons
Flag any cross-platform design contamination.

### 2.5 Accessibility (WCAG 2.1 AA)
VoiceOver vs TalkBack support, Dynamic Type vs font scaling at 200%, color contrast on 5 most critical screens, accessibility labels on all interactive elements, reduced motion, Switch Control / Switch Access, semantic heading structure.

### 2.6 Localization Readiness
Externalized strings? Hardcoded string grep. String key conventions. Locale-aware formatting (numbers, dates, units, plurals). RTL support. String length accommodation.

---

## SECTION 3: ARCHITECTURE
*Perspective: Solutions Architect + CTO + Principal Engineer*

### 3.1 Pattern
Describe each app's architecture (MVC, MVVM, MVI, Clean, TCA, Redux). Diagram the dependency graph. Assess consistency.

### 3.2 Separation of Concerns
Business logic isolated from UI? Data access behind repositories? Platform concerns encapsulated? Shared/KMP layer present or needed?

### 3.3 Module Structure
Feature modules vs layer modules vs monolith. Circular dependencies? Visibility enforcement?

### 3.4 Scalability
How hard is it to add a new feature? Extension points documented? Architecture Decision Records present?

### 3.5 Technical Debt Inventory
- `grep -rn "TODO\|FIXME\|HACK\|XXX\|TEMP\|WORKAROUND" --include="*.swift" --include="*.kt" --include="*.java"` — list every hit with context
- God classes > 500 LOC
- Dead code: unused classes, functions, imports, assets, feature flags
- Copy-pasted blocks within and across platforms

---

## SECTION 4: CODE QUALITY
*Perspective: Principal Engineer*

### 4.1 Metrics
Top 10 cyclomatic complexity hotspots per platform. Largest files by LOC. Deepest nesting. Longest parameter lists.

### 4.2 Error Handling
Empty catch blocks (grep for them). User-facing error message consistency. Edge case coverage: no network, no GPS, no permissions, disk full, corrupt data. Force unwraps (`!` in Swift) and unchecked casts (`as` in Kotlin) — list every instance.

### 4.3 Concurrency
- **iOS**: @MainActor, DispatchQueue discipline, async/await, actors, Sendable, data race potential
- **Android**: Coroutine scope lifecycle, Dispatchers, GlobalScope usage, main-safety, StateFlow thread safety
- **Both**: Shared mutable state without synchronization

### 4.4 Memory & Performance
- **iOS**: Retain cycles (missing `[weak self]`), large allocations in loops
- **Android**: Context leaks, Activity/Fragment references in long-lived objects, Bitmap handling
- **Both**: Real-time performance in capture path, startup time, memory footprint

### 4.5 Dependency Injection
DI approach per platform. Injectability and testability. Singleton audit with justification assessment.

---

## SECTION 5: SECURITY
*Perspective: Security Engineer + CTO*

### 5.1 Threat Model
What sensitive data? Who are adversaries? (Curious users, network attackers, physical access, malicious open-source contributors.) Highest-impact scenarios?

### 5.2 Data at Rest
iOS: Keychain, Data Protection classes, file protection on DBs/exports. Android: EncryptedSharedPreferences, AndroidKeyStore, SQLCipher. Unencrypted sensitive data in UserDefaults/SharedPreferences?

### 5.3 Data in Transit
HTTPS everywhere? HTTP exceptions in ATS / network_security_config.xml? Certificate pinning? Secure token transmission?

### 5.4 Secrets Hygiene
Run on both codebases:
```bash
grep -rn "api_key\|apikey\|secret\|password\|token\|credential\|private_key\|BEGIN RSA\|BEGIN PRIVATE" --include="*.swift" --include="*.kt" --include="*.java" --include="*.xml" --include="*.plist" --include="*.json" --include="*.gradle" --include="*.yml" --include="*.yaml" --include="*.env" --include="*.xcconfig"
```
Check `.gitignore`. Search git history: `git log --all -p -S "api_key" --source | head -50` and similar for secret, password, token.

### 5.5 Input Validation
SQL injection (raw queries with interpolation). Path traversal. Intent/URL scheme injection. Untrusted deserialization.

### 5.6 Privacy Surface
What data leaves device, and where? Analytics anonymization? ATT (iOS) / advertising ID (Android) respect? Data minimization? Retention/purge mechanism?

### 5.7 Hardening
iOS: stripped binary, anti-debug. Android: ProGuard/R8, root detection, debuggable=false in release. Both: screenshot prevention, clipboard clearing, app switcher blurring.

---

## SECTION 6: TESTING
*Perspective: SDET*

### 6.1 Inventory
Count actual test files and build:

| Type | iOS Count | Android Count | Parity? | Notes |
|------|-----------|---------------|---------|-------|
| Unit | | | | |
| Integration | | | | |
| UI/E2E | | | | |
| Snapshot | | | | |
| Performance | | | | |
| Fuzz/Property | | | | |

### 6.2 Coverage
Estimate or run coverage. Top 20 highest-risk untested paths ranked by user impact.

### 6.3 Parity
For every test on iOS, confirm equivalent on Android (and vice versa). Focus: core calculations (identical inputs → identical outputs), data persistence, validation, error handling.

### 6.4 Quality
Meaningful assertions vs smoke tests? Flaky indicators (sleep, hardcoded dates, network)? Test data management? Mock/stub quality?

### 6.5 CI/CD
Pipeline comparison. Tests on every PR? Linting/static analysis rulesets? Automated distribution? Release candidate smoke suite?

---

## SECTION 7: DEPENDENCIES & SUPPLY CHAIN
*Perspective: Security Engineer + Licensing Counsel + CTO*

### 7.1 Inventory
Build for both platforms:

| Dependency | Version | Platform | Purpose | License | Last Updated | CVEs | Transitive Count |
|------------|---------|----------|---------|---------|-------------|------|-----------------|

### 7.2 Health
Flag: unmaintained (12+ months), known CVEs, excessive transitive deps, single-maintainer risk, abandoned forks.

### 7.3 License Compliance
Every dependency license listed. Flag: incompatible with project license, copyleft (GPL/AGPL/LGPL), ambiguous. Attribution obligations met? Third-party license screen in both apps?

### 7.4 Equivalence
Same library for same purpose across platforms? Unnecessary divergences? Eliminable dependencies?

---

## SECTION 8: BUILD & RELEASE
*Perspective: Release Engineer + CTO*

### 8.1 Configuration
Min OS versions aligned? Dependency managers compared. Build variants/schemes equivalent. ProGuard/R8 rules tested. dSYM/mapping files generated. Debug flags OFF in release. Test credentials removed.

### 8.2 Signing
iOS provisioning/certs. Android keystore. Signing credentials excluded from repo.

### 8.3 Feature Flags
List all flags with state per platform. Remote config defaults consistent? Flags to enable or remove before launch?

### 8.4 Store Metadata
Bundle IDs, versions aligned. Icons at all resolutions. Launch screens. Privacy manifests (iOS) and data safety (Play Store). Permissions with rationale strings. Category/keywords/description consistency.

### 8.5 Rollback
Phased rollout strategy? Remote kill switch via feature flags? Hotfix process for both platforms?

---

## SECTION 9: PRODUCT STRATEGY
*Perspective: Product Manager + CEO + CPO*

### 9.1 User Journeys
Walk end-to-end on both platforms. Note every friction point, dead end, or divergence:
1. First Launch → permissions → onboarding → first measurement → value delivered
2. Core Loop → capture → review → insights
3. Return Visit → find past sessions → compare → export/share
4. Settings → change prefs → verify persistence
5. Recovery → deny permission → attempt feature → re-grant → resume
6. Sharing → generate report → share → recipient experience

### 9.2 Degraded Experience Matrix
Build and fill:

| Scenario | iOS | Android | Acceptable? |
|----------|-----|---------|-------------|
| Location denied | | | |
| "While Using" only | | | |
| Weak GPS | | | |
| Airplane mode mid-session | | | |
| App backgrounded mid-capture | | | |
| App killed mid-capture | | | |
| Storage full | | | |
| 1000+ data points in session | | | |
| Clock wrong | | | |
| OS upgrade with data | | | |
| App update migration | | | |
| Low battery mode | | | |
| Screen recording active | | | |

### 9.3 Analytics & Observability
Event names/properties identical? Crash reporting configured? Diagnostic breadcrumbs? Enough telemetry for key metrics (DAU, sessions, feature adoption, funnels)?

### 9.4 Product-Market Fit
Value proposition clear within 60 seconds? Core insight understandable to non-technical user? CTA after completing session? Sharing optimized for virality?

---

## SECTION 10: BRAND & GO-TO-MARKET
*Perspective: CMO + CEO*

### 10.1 Brand Consistency
Name, tagline, description consistent everywhere? Icon pixel-identical? Color palette matched? Typography hierarchy? Copy tone of voice?

### 10.2 ASO
App Store and Play Store: title, subtitle, description, keywords. Screenshots: equivalent quality, same features, correct frames. Preview videos?

### 10.3 Growth Mechanics
What's shared, in what format, with what branding? Link back to app? Invite flow? Social proof?

### 10.4 Launch Readiness
Press kit? Open-source announcement materials (blog, social, HN)? GitHub README compelling?

---

## SECTION 11: OPEN-SOURCE GOVERNANCE
*Perspective: CTO + Licensing Counsel + CEO*

### 11.1 License
LICENSE file present? Appropriate license? License headers on all source files?

### 11.2 Contributor Infrastructure
- CONTRIBUTING.md (code of conduct, setup, standards, PR process, issue triage)
- CHANGELOG.md
- Issue templates (bug, feature, parity issue)
- PR template
- CI on contributor PRs

### 11.3 IP & Secret Scrubbing
ALL credentials, keys, internal URLs, employee names, proprietary references removed from: source, config, comments, commit messages, git history, build scripts, docs. `.env.example` present? `SECURITY.md` with vulnerability disclosure?

### 11.4 Repository Hygiene
Git history clean for public? Large binaries in LFS or excluded? `.gitignore` comprehensive? CI badges? External-contributor-friendly CI?

---

## SECTION 12: LEGAL & COMPLIANCE
*Perspective: Licensing Counsel + CEO + CPO*

### 12.1 Privacy & Data Protection
Privacy Policy exists, in-app, accurate? Terms of Service? GDPR (access, portability, deletion)? CCPA? COPPA (age-gating for minors)? Location data disclosed and minimized? Analytics consent and opt-out?

### 12.2 Regulatory
Export control (encryption classification). Measurement accuracy disclaimers. Jurisdiction-specific traffic monitoring rules.

### 12.3 Third-Party Obligations
Complete license obligation matrix. Attribution met? NOTICE files for Apache 2.0? Source availability for LGPL? Acknowledgment screen in both apps?

---

## SECTION 13: OUTPUT REPORT

Produce the final report in **exactly this structure**:

### 1. Executive Summary (5 sentences max)
- Overall launch readiness: A / B / C / D / F
- Platform parity grade: A / B / C / D / F
- Open-source readiness grade: A / B / C / D / F
- Top 3 risks

### 2. Critical Blockers (P0)
Each: ID (BLOCK-NNN) | Platform | Stakeholder | Description | Evidence (file:line) | Fix | Effort

### 3. High Priority (P1)
Same format.

### 4. Feature Parity Matrix (Section 1.1 table)

### 5. Degraded Experience Matrix (Section 9.2 table)

### 6. Dependency & License Matrix (Section 7.1 table)

### 7. Detailed Findings (P2/P3)
Organized by section. Each: Severity | Platform | Stakeholder | Description with code refs | Fix | Effort

### 8. Pre-Launch Checklist
Ordered by priority:
- [ ] Task
- Priority: P0-P3
- Effort: S/M/L/XL
- Owner: iOS / Android / Backend / Design / Product / Legal / DevOps
- Depends on: (if any)

### 9. Post-Launch Watch List
30-day monitoring: performance metrics, crash rate thresholds, feature adoption targets, known issues.

---

**Begin the review now. Start with Phase 1 (repo orientation and feature inventory), then proceed through all sections.**
