---
paths:
  - "**/*.kt"
  - "**/*.kts"
  - "**/build.gradle*"
  - "**/settings.gradle*"
---

# Kotlin / Android

- UI framework: Jetpack Compose (prefer over XML layouts for new code)
- Build system: Gradle with Kotlin DSL
- Linting/formatting: ktlint
- Style: ktlint defaults, 4-space indent
- Prefer `data class`, `sealed class`/`sealed interface`, `value class`
- Use coroutines + Flow for async, `StateFlow` for UI state
- Follow Android Architecture Components patterns (ViewModel, Repository)
