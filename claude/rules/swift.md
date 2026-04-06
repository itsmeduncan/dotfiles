---
paths:
  - "**/*.swift"
  - "**/Package.swift"
  - "**/*.xcodeproj/**"
  - "**/*.xcworkspace/**"
---

# Swift / iOS

- UI framework: SwiftUI (prefer over UIKit for new code)
- Linting: swiftlint
- Formatting: swiftformat
- Dependency management: Swift Package Manager (preferred), cocoapods (legacy)
- Style: swiftlint defaults, 4-space indent
- Prefer structured concurrency (`async`/`await`, `TaskGroup`) over callbacks
- Use `@Observable` macro (iOS 17+) over `ObservableObject` for new code
- Xcode toolchain via `xcrun`, build with `xcodebuild`
