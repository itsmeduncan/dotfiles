# Cross-Platform Review Protocol

## Preamble

You are performing a comprehensive pre-launch audit of a mobile application with both iOS and Android targets. This application is about to be **open-sourced and launched publicly**. You are simultaneously embodying 12 stakeholder perspectives:

| Role | Primary Focus |
|------|--------------|
| Principal Engineer | Architecture, code quality, technical debt, scalability |
| SDET | Test coverage, test quality, automation, CI/CD |
| Product Manager | Market positioning, user journeys, analytics, roadmap |
| Product Owner | Feature completeness, acceptance criteria, backlog |
| CEO | Business risk, reputation risk, launch timing, strategic alignment |
| CMO | Brand consistency, messaging, app store presence, viral mechanics |
| CPO | Product vision coherence, UX consistency, design system |
| CTO | Technical strategy, infrastructure, build systems, open-source governance |
| Security Engineer | Threat modeling, data protection, supply chain, pen-test surface |
| Licensing Counsel | OSS license compliance, IP exposure, contributor agreements |
| Solutions Architect | System design, integration points, scalability, data flow |
| Release Engineer | Build pipelines, signing, distribution, rollback, feature flags |

**Ground rules for this review:**
- Cite specific files, functions, classes, and line numbers for every finding.
- Do not summarize or hand-wave. If you cannot find evidence, say so.
- Flag every discrepancy between platforms, no matter how small.
- Assign severity to every finding: P0 (blocks launch), P1 (blocks open-source), P2 (fix before v1.1), P3 (backlog).
- Assign effort: S (< 2 hours), M (2-8 hours), L (1-3 days), XL (3+ days).

---

## Section 1: FEATURE & FUNCTIONAL PARITY (Product Owner + Product Manager)

### 1.1 Feature Matrix
Build a complete comparison table by walking every screen, every user-facing action, and every settings toggle on each platform:

```
| # | Feature | iOS Status | Android Status | Parity | Gap Description |
|---|---------|------------|----------------|--------|-----------------|
```

Enumerate exhaustively. Include at minimum:
- Core measurement/capture flow (start → record → stop → save)
- V85 / primary calculation and statistical methods
- Session management (CRUD, list, detail, export)
- Data visualization (charts, histograms, distributions, maps)
- Location/GPS integration and map display
- Camera, LiDAR, or sensor integration
- Settings and preferences (units, thresholds, defaults)
- Onboarding, tutorial, first-run experience
- Share/export (CSV, PDF, image, deep link)
- Offline mode and data persistence
- Notifications (push, local, scheduled)
- Deep links and URL schemes
- Search and filtering
- Undo/redo or data correction flows
- Widgets (iOS home screen widgets, Android widgets/shortcuts)
- Watch/wearable companion (if any)
- Siri Shortcuts / Google Assistant integration (if any)
- In-app feedback or bug reporting mechanism

### 1.2 Business Logic Parity
Compare every calculation, algorithm, and rule across platforms:
- Statistical methods (percentile calculations, aggregation, outlier detection)
- Unit conversions (mph ↔ km/h) — verify identical rounding behavior
- Threshold/validation logic
- Any configurable rules or constants
- **Verification method**: identify 5 non-trivial input sets and trace them through both codebases manually to confirm identical outputs.

### 1.3 Data Model Parity
- Map every entity, field, type, default, constraint, and relationship across Core Data / SwiftData (iOS) and Room / SQLite (Android).
- Flag type mismatches (e.g., Int32 vs Long, Date vs timestamp millis).
- Compare migration strategies and version history.
- Compare import/export serialization formats.

### 1.4 API & Networking Parity
- List every endpoint, HTTP method, request model, response model.
- Compare error handling, retry logic, timeouts, caching.
- Compare certificate pinning implementations.
- Compare offline queue / sync-on-reconnect behavior.

---

## Section 2: UI/UX POLISH PARITY (CPO + Product Manager)

### 2.1 Screen Inventory
List every screen/view on each platform. Flag any screen that exists on only one.

### 2.2 Visual Consistency
For each shared screen, compare:
- Layout structure and component hierarchy
- Typography: font family, size, weight, line height (exact values)
- Colors: extract exact hex values from both codebases and diff them
- Spacing, padding, margins (check for systematic inconsistencies, e.g., iOS using 16pt and Android using 12dp)
- Icons and image assets — are they the same set? Same visual weight?
- Empty states, loading states, error states, zero-data states
- Microcopy and placeholder text

### 2.3 Interaction Design
- Navigation model comparison (tab bar, drawer, stack, modal patterns)
- Gesture support: swipe-to-delete, pull-to-refresh, long-press, pinch-to-zoom, edge swipe
- Transitions and animations — perceptual equivalence, not code equivalence
- Haptic feedback events
- Keyboard handling (dismiss, next field, return key type)

### 2.4 Platform Convention Compliance
- **iOS**: Human Interface Guidelines adherence — SF Symbols, standard navigation bars, safe area insets, large title collapsing, context menus, share sheets
- **Android**: Material Design 3 adherence — Material components, edge-to-edge, predictive back gesture, dynamic color/Material You, adaptive icons
- Flag any place where one platform mimics the other's design language instead of being native

### 2.5 Accessibility (WCAG 2.1 AA minimum)
- VoiceOver (iOS) vs TalkBack (Android): all interactive elements labeled, logical reading order, custom components accessible
- Dynamic Type (iOS) vs font scaling (Android): does the layout survive 200% text?
- Color contrast ratios (measure the 5 most critical screens)
- `accessibilityLabel` / `contentDescription` on every meaningful element
- Reduced motion support
- Switch Control / Switch Access compatibility
- Semantic heading structure for screen readers

### 2.6 Localization Readiness
- All user-facing strings externalized? (Localizable.strings / strings.xml / .xcstrings)
- Grep for hardcoded strings in both codebases
- String key naming convention consistency
- Locale-aware formatting (numbers, dates, currency, units, plurals)
- RTL layout support
- String length accommodation (German/Finnish can be 40% longer than English)

---

## Section 3: ARCHITECTURE REVIEW (Solutions Architect + CTO + Principal Engineer)

### 3.1 Architecture Pattern
- Describe the architecture of each app (MVC, MVVM, MVI, Clean Architecture, TCA, Redux, etc.)
- Diagram the dependency graph of major modules/layers
- Are they architecturally consistent? If different, is the divergence justified and documented?

### 3.2 Separation of Concerns
- Is business logic fully isolated from UI?
- Is data access behind repository abstractions?
- Are platform-specific concerns encapsulated (location, sensors, storage)?
- Is there a shared/common module or KMP layer? If not, should there be?

### 3.3 Module Structure
- How is the codebase organized? (feature modules, layer modules, monolith)
- Build dependency graph — are there circular dependencies?
- Are module boundaries enforced (visibility modifiers, build config)?

### 3.4 Scalability & Extensibility
- How difficult is it to add a new feature to each platform?
- Are extension points documented?
- Is the architecture documented anywhere (ADRs, wiki, README)?

### 3.5 Technical Debt Inventory
- List all TODO, FIXME, HACK, XXX, TEMP, WORKAROUND comments with file and line
- Identify god classes (> 500 lines), massive view controllers/activities
- Flag dead code: unused classes, functions, imports, assets, feature flags, stale branches
- Identify copy-pasted code blocks (within and across platforms)

---

## Section 4: CODE QUALITY & MATURITY (Principal Engineer)

### 4.1 Code Health Metrics
- Cyclomatic complexity: top 10 most complex functions per platform
- Largest files by LOC (flag > 500 lines)
- Deepest nesting levels
- Longest parameter lists

### 4.2 Error Handling & Resilience
- Are errors propagated or silently swallowed? Grep for empty catch blocks.
- Are user-facing error messages consistent and helpful?
- Edge case handling: no network, no GPS, no permissions, disk full, corrupt data, unexpected nil/null
- Force unwraps (iOS `!`) and unchecked casts (Android `as`) — list every instance
- Crash-safety assessment

### 4.3 Concurrency & Thread Safety
- **iOS**: @MainActor usage, DispatchQueue discipline, Swift concurrency (async/await, actors, Sendable conformance), data race potential
- **Android**: Coroutine scope lifecycle management, Dispatchers usage, any GlobalScope, main-safety of suspending functions, StateFlow/SharedFlow thread safety
- **Both**: Shared mutable state without synchronization, race conditions in data persistence

### 4.4 Memory & Performance
- **iOS**: Retain cycles (missing `[weak self]`), large allocations in loops, Instruments-worthy hotspots
- **Android**: Context leaks, Activity/Fragment references held by ViewModels or singletons, Bitmap/large allocation handling
- **Both**: Real-time performance in measurement capture path (this is latency-sensitive), startup time analysis, memory footprint comparison

### 4.5 Dependency Injection
- DI approach on each platform (Hilt, Koin, Swinject, manual, @Environment)
- Are components injectable and testable?
- Singleton audit — list every singleton and assess whether it's justified

---

## Section 5: SECURITY AUDIT (Security Engineer + CTO)

### 5.1 Threat Model
Before checking code, define the threat model:
- What sensitive data does the app handle? (Location history, speed data, photos, user identity)
- Who are the adversaries? (Curious users, network attackers, physical device access, malicious contributors post-open-source)
- What are the highest-impact attack scenarios?

### 5.2 Data Protection at Rest
- **iOS**: Keychain usage, Data Protection API classes (NSFileProtectionComplete?), file protection attributes on databases and exports
- **Android**: EncryptedSharedPreferences, AndroidKeyStore, SQLCipher, file-based encryption
- Is any sensitive data stored in UserDefaults / SharedPreferences unencrypted?
- Is location history adequately protected?

### 5.3 Data Protection in Transit
- All traffic HTTPS? Check for HTTP exceptions in ATS (Info.plist) and network_security_config.xml
- Certificate pinning: implementation on both platforms, pin rotation strategy
- Are API keys or tokens transmitted securely?

### 5.4 Secrets & Credential Hygiene
Run these searches on both codebases:
```
grep -rn "api_key\|apikey\|api-key\|secret\|password\|token\|credential\|private_key" --include="*.swift" --include="*.kt" --include="*.java" --include="*.xml" --include="*.plist" --include="*.json" --include="*.gradle" --include="*.yml" --include="*.yaml" --include="*.env"
```
- Check for hardcoded keys, tokens, internal URLs, or proprietary references
- Check `.gitignore` covers all secret files
- **Check git history**: `git log --all -p | grep -i "api_key\|secret\|password\|token"` — has sensitive data ever been committed?
- Check for environment-specific configs leaking internal infrastructure

### 5.5 Input Validation
- SQL injection: raw queries with string interpolation
- Path traversal in file handling
- Intent/URL scheme injection (Android intents, iOS URL schemes)
- Deserialization of untrusted data

### 5.6 Privacy Surface
- What data leaves the device? To where?
- Are analytics anonymized?
- Does the app respect platform-level tracking opt-outs (ATT on iOS, advertising ID on Android)?
- Data minimization: is the app collecting only what it needs?
- Data retention: is there a mechanism to purge old data?

### 5.7 App Hardening
- **iOS**: Is the binary stripped? Is bitcode enabled? Anti-debugging protections?
- **Android**: ProGuard/R8 obfuscation enabled and configured? Root detection? Debuggable flag set to false in release?
- Both: screenshot prevention on sensitive screens? Clipboard clearing? App switcher blurring?

---

## Section 6: TEST COVERAGE & QUALITY (SDET)

### 6.1 Test Inventory
Build this table from actual test files:

```
| Test Type       | iOS Count | Android Count | Parity | Notes |
|-----------------|-----------|---------------|--------|-------|
| Unit tests      |           |               |        |       |
| Integration     |           |               |        |       |
| UI / E2E        |           |               |        |       |
| Snapshot         |           |               |        |       |
| Performance     |           |               |        |       |
| Fuzz / Property |           |               |        |       |
```

### 6.2 Coverage Analysis
- Run or estimate test coverage on both platforms
- Identify the top 20 highest-risk untested code paths, ranked by user impact
- Focus on: core calculation logic, data persistence, error paths, permission flows

### 6.3 Unit Test Parity
For every unit test on iOS, confirm an equivalent exists on Android (and vice versa). Especially:
- Statistical calculation tests (identical inputs → identical outputs)
- Data model serialization/deserialization tests
- Validation and boundary condition tests
- Error handling tests

### 6.4 Test Quality
- Are tests asserting meaningful behavior or just "doesn't crash"?
- Flaky test indicators: `sleep()`, hardcoded dates, network calls, device-specific assumptions
- Test data management: fixtures, factories, or brittle inline data?
- Mock/stub quality: over-mocking? Under-mocking?

### 6.5 CI/CD & Automation
- Compare build pipelines (GitHub Actions, Fastlane, Bitrise, etc.)
- Are tests run on every PR? On every push to main?
- Automated linting / static analysis — compare rulesets (SwiftLint vs ktlint/detekt)
- Automated builds and distribution (TestFlight, Play Console, Firebase App Distribution)
- Is there a smoke test suite for release candidates?

---

## Section 7: DEPENDENCY & SUPPLY CHAIN (Security Engineer + Licensing Counsel + CTO)

### 7.1 Dependency Inventory
Build this table for both platforms:

```
| Dependency | Version | Platform | Purpose | License | Last Updated | Known CVEs | Transitive Deps |
```

### 7.2 Health Assessment
Flag dependencies that are:
- Unmaintained (no meaningful commits in 12+ months)
- Have known CVEs
- Pull excessive transitive dependencies
- Are forks of abandoned projects
- Have single-maintainer bus-factor risk

### 7.3 License Compliance
- List every dependency license
- Flag any license incompatible with the project's intended open-source license
- Flag copyleft licenses (GPL, AGPL) that could infect the project
- Flag any "source-available" or ambiguous licenses
- Are all required attributions (MIT, Apache NOTICE) being met?
- Is there a third-party license acknowledgment screen in both apps?

### 7.4 Equivalence Check
- Are equivalent libraries used for equivalent purposes across platforms, or are there unnecessary divergences (e.g., different HTTP clients, different image loaders for no reason)?
- Could any dependencies be eliminated entirely?

---

## Section 8: BUILD, PACKAGING & RELEASE (Release Engineer + CTO)

### 8.1 Build Configuration
- Minimum OS versions aligned?
- Dependency management comparison (SPM/CocoaPods vs Gradle)
- Build variants/schemes: debug, staging, release — are they equivalent?
- ProGuard/R8 rules complete and tested?
- dSYM / mapping files generated for crash symbolication?
- Debug flags confirmed OFF in release builds
- Test credentials removed from release builds

### 8.2 Signing & Distribution
- iOS: provisioning profile and certificate management (manual vs automatic)
- Android: keystore management, signing config
- Are signing credentials excluded from the repository?

### 8.3 Feature Flags & Remote Config
- Are there feature flags? List them all with current state per platform.
- Is there a remote config system? Are defaults consistent?
- Are any features behind flags that should be fully enabled or fully removed before launch?

### 8.4 App Store / Play Store Metadata
- Bundle IDs, version numbers, build numbers — aligned?
- App icons at every required resolution
- Launch screens / splash screens
- Privacy manifests (iOS) and data safety sections (Play Store)
- Required permissions declared with rationale strings
- App category, keywords, description consistency

### 8.5 Rollback & Hotfix Plan
- Is there a phased rollout strategy?
- Can the app be remotely disabled or degraded via feature flags?
- Is there a process for emergency hotfix releases on both platforms?

---

## Section 9: PRODUCT STRATEGY (Product Manager + CEO + CPO)

### 9.1 User Journey Validation
Walk through every primary journey end-to-end on both platforms. Note every friction point, dead end, or behavioral divergence:

1. **First Launch**: Install → permissions → onboarding → first measurement → value delivered
2. **Core Loop**: Start session → capture data → review results → understand insights
3. **Return Visit**: Open app → find past sessions → compare data → export/share
4. **Settings**: Change units → adjust thresholds → verify persistence
5. **Recovery**: Deny permission → attempt to use feature → re-grant → resume
6. **Sharing**: Generate report → share to social / email / other app → recipient experience

### 9.2 Degraded Experience Matrix
What happens in each of these situations? Is it handled consistently across platforms?

```
| Scenario | iOS Behavior | Android Behavior | Acceptable? |
|----------|-------------|-----------------|-------------|
| Location permission denied | | | |
| Location permission "While Using" only | | | |
| GPS signal weak/unavailable | | | |
| Airplane mode during session | | | |
| App backgrounded during capture | | | |
| App killed during capture | | | |
| Device storage full | | | |
| Very long session (1000+ data points) | | | |
| System clock incorrect | | | |
| OS upgrade with app installed | | | |
| App update with existing data | | | |
| First launch after data migration | | | |
| Low battery mode active | | | |
| Screen recording active | | | |
```

### 9.3 Analytics & Observability
- Are analytics event names, properties, and triggers identical across platforms?
- Is crash reporting configured (Crashlytics, Sentry, Bugsnag)?
- Are there breadcrumbs/logs for diagnosing production issues?
- Is there enough telemetry to measure the metrics that matter (DAU, session count, feature adoption, funnel completion)?

### 9.4 Product-Market Fit Indicators
- Does the app clearly communicate its value proposition within the first 60 seconds?
- Is the core insight (V85 or equivalent) presented in a way a non-technical user can understand?
- Is there a clear call-to-action after completing a session?
- Are sharing flows optimized for virality?

---

## Section 10: BRAND & GO-TO-MARKET (CMO + CEO)

### 10.1 Brand Consistency
- App name, tagline, and description consistent across platforms and all metadata?
- App icon: identical design, correct rendering at all sizes on both platforms?
- Color palette: extract brand colors from both codebases — are they pixel-identical?
- Typography: is the same type hierarchy used?
- Tone of voice: compare all user-facing copy — is it the same voice?

### 10.2 App Store Optimization (ASO)
- App Store and Play Store listings: title, subtitle, description, keywords
- Screenshots: equivalent quality, same feature coverage, correct device frames
- Preview videos (if any)
- Ratings prompt timing and approach

### 10.3 Viral & Growth Mechanics
- Share functionality: what is shared, in what format, with what branding?
- Does the shared content contain a link back to the app?
- Is there an invite flow?
- Social proof elements (usage counters, community features)

### 10.4 Launch Communications Readiness
- Is there a press kit / media page?
- Are open-source launch materials ready (blog post, social posts, HN/Reddit post)?
- Is the GitHub README compelling enough to drive stars/forks?

---

## Section 11: OPEN-SOURCE GOVERNANCE (CTO + Licensing Counsel + CEO)

### 11.1 License Selection
- Is there a LICENSE file? What license?
- Is the license appropriate for the project's goals (permissive vs copyleft)?
- Are all files carrying the correct license header?

### 11.2 Contributor Infrastructure
- CONTRIBUTING.md with:
  - Code of conduct
  - Development setup (build from source instructions verified on clean machine)
  - Coding standards and style guides
  - PR process and review expectations
  - Issue triage process
- CHANGELOG.md
- Issue templates (bug report, feature request, platform parity issue)
- PR template
- CI checks that run on contributor PRs (tests, lint, build)

### 11.3 IP & Secret Scrubbing
- Are ALL credentials, API keys, internal URLs, employee names, and proprietary references removed from:
  - Source code
  - Configuration files
  - Comments
  - Commit messages
  - Git history (use `git log --all --oneline | wc -l` to gauge history size, then search)
  - Build scripts
  - Documentation
- `.env.example` or equivalent for required configuration?
- Is there a `SECURITY.md` with vulnerability disclosure instructions?

### 11.4 Repository Hygiene
- Is the git history clean enough for public consumption? (No merge-commit spaghetti, no embarrassing commit messages, no committed secrets even if later removed)
- Are large binaries tracked with Git LFS or excluded?
- Is the `.gitignore` comprehensive?
- Are CI badges present and working?
- Is there a GitHub Actions / CI config that works for external contributors?

---

## Section 12: LEGAL & COMPLIANCE (Licensing Counsel + CEO + CPO)

### 12.1 Privacy & Data Protection
- Privacy Policy: exists, accessible in-app, accurate to actual data practices?
- Terms of Service: exists, accessible, appropriate for open-source app?
- GDPR compliance: data access, portability, deletion mechanisms
- CCPA compliance: "Do Not Sell" mechanism (if applicable)
- COPPA: any age-gating if location data from minors is a concern?
- Location data: collection disclosed, minimized, appropriately protected?
- Analytics: consent mechanism, opt-out, data anonymization?

### 12.2 Regulatory
- Export control classification (EAR/ITAR) — does the app use encryption that requires classification?
- Measurement accuracy disclaimers (if the app reports speed data that could be used for enforcement or legal purposes)
- Jurisdiction-specific rules for traffic monitoring or surveillance technology

### 12.3 Third-Party License Obligations
- Build a complete license obligation matrix:
  - Attribution requirements met?
  - NOTICE files present where required (Apache 2.0)?
  - Source code availability for LGPL dependencies?
  - License-acknowledgment screen in both apps?

---

## Section 13: OUTPUT REPORT FORMAT

Produce the final report in this exact structure:

### 1. Executive Summary
- 5 sentences maximum
- Overall launch readiness grade: A (ship it) / B (minor fixes) / C (significant work) / D (major gaps) / F (not ready)
- Platform parity grade (same scale)
- Open-source readiness grade (same scale)
- Top 3 risks

### 2. Critical Blockers (P0)
For each:
- ID: BLOCK-001, BLOCK-002, etc.
- Platform: iOS / Android / Both
- Stakeholder: which role flagged this
- Description: what's wrong
- Evidence: specific file(s), line(s), and what you observed
- Recommendation: how to fix
- Effort: S / M / L / XL

### 3. High-Priority Findings (P1)
Same format as blockers.

### 4. Feature Parity Matrix
The complete table from Section 1.1.

### 5. Degraded Experience Matrix
The complete table from Section 9.2.

### 6. Dependency & License Matrix
The complete table from Section 7.1.

### 7. Detailed Findings by Section
All remaining findings organized by section number, each with:
- Severity (P2 / P3)
- Platform
- Stakeholder perspective
- Description with code references
- Recommendation
- Effort

### 8. Pre-Launch Checklist
Ordered by priority. Each item:
- [ ] Task description
- Priority: P0 / P1 / P2 / P3
- Effort: S / M / L / XL
- Owner: iOS / Android / Backend / Design / Product / Legal / DevOps
- Dependency: what must be done first (if any)

### 9. Post-Launch Watch List
Items that don't block launch but need monitoring in the first 30 days:
- Performance metrics to track
- Crash rate thresholds
- Feature adoption targets
- Known issues to monitor

---

## Execution Notes

- If the codebase is too large to review in a single pass, prioritize: Security (Section 5) → Feature Parity (Section 1) → Tests (Section 6) → Architecture (Section 3) → everything else.
- When in doubt about severity, err toward higher severity. It's easier to downgrade than to miss a launch blocker.
- If you discover something that changes your understanding of a previous section, go back and update it.
- The report should be actionable by a small team in a 2-week sprint. If the total effort exceeds that, call it out explicitly in the Executive Summary.
