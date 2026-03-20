//
//  ConcurrencyGuide.swift
//  MyApp
//
//  Swift 6.2 Concurrency Configuration Guide
//
//  This project is prepared for Swift 6 strict concurrency.
//
//  Current status:
//  - All ViewModels use @Observable @MainActor
//  - All model types conform to Sendable
//  - All App Intents use await MainActor.run {} for @MainActor access
//  - No DispatchQueue.main.async (replaced with @MainActor)
//  - No import Combine (replaced with async/await)
//
//  To enable strict concurrency in Xcode:
//  1. Build Settings > Swift Compiler - Upcoming Features
//  2. Enable "Strict Concurrency Checking" (SWIFT_STRICT_CONCURRENCY = complete)
//  3. For Swift 6.2+, enable "Nonisolated Nonsending By Default"
//  4. For Swift 6.2+, enable "Default Actor Isolation" (@MainActor default)
//
//  Annotations used:
//  - @MainActor: All ViewModels, UI-bound managers
//  - @Sendable: Closures crossing isolation boundaries
//  - @ObservationIgnored: Non-UI properties in @Observable classes
//  - nonisolated: Properties that must be accessed from any context
//
//  Known areas requiring @concurrent when Swift 6.2 is fully adopted:
//  - LibraryViewModel.fetchEntries() network calls (heavy I/O)
//  - LibraryCacheManager disk operations
//  - CachedAsyncImage network fetching
//  - KeychainHelper Security framework calls
//
//  Migration checklist for Swift 6.2:
//  1. Set SWIFT_STRICT_CONCURRENCY = complete in build settings
//  2. Add @concurrent to functions that perform off-main-actor I/O
//  3. Audit all @Sendable closures for captured mutable state
//  4. Convert remaining DispatchQueue.global() calls to structured concurrency
//  5. Verify all protocol conformances satisfy Sendable requirements
//  6. Test with Thread Sanitizer enabled (TSan) in Xcode scheme
//
//  Build setting reference (Package.swift or Xcode):
//  ```
//  // Package.swift
//  swiftSettings: [
//      .enableUpcomingFeature("StrictConcurrency"),
//      .enableUpcomingFeature("GlobalActorIsolatedTypesUsability"),
//      .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
//  ]
//
//  // Xcode Build Settings
//  SWIFT_STRICT_CONCURRENCY = complete
//  OTHER_SWIFT_FLAGS = -enable-upcoming-feature StrictConcurrency
//  ```
//

import Foundation
// This file is documentation only - no executable code
