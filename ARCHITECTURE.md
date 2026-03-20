# Architecture Guide

This document explains the patterns and structure of SwiftUI Indie Stack. Follow these patterns when adding new features to maintain consistency.

---

## Core Principles

1. **Offline-First**: Local storage is the source of truth. Cloud sync is optional.
2. **Feature Flags**: Everything can be toggled via `AppConfiguration.swift`.
3. **Conditional Compilation**: Optional dependencies use `#if canImport()`.
4. **Consistent Patterns**: Every feature follows the same structure.

---

## Design Pattern: MVVM

This project uses **MVVM (Model-View-ViewModel)**, the most common design pattern for SwiftUI applications.

### Why MVVM?

MVVM is a natural fit for SwiftUI because Apple's property wrappers map directly to the pattern:

| Component     | Role                   | SwiftUI Implementation                      |
| ------------- | ---------------------- | ------------------------------------------- |
| **Model**     | Data structures        | `Codable` structs                           |
| **ViewModel** | State + business logic | `@Observable` classes with plain properties |
| **View**      | UI rendering           | SwiftUI views observing ViewModels          |

**Benefits for this starter kit:**

- **Testable**: Business logic lives in ViewModels, separate from UI
- **Scalable**: Add features without rewiring existing code
- **SwiftUI-native**: Uses `@Observable` (iOS 17+) for fine-grained observation
- **Approachable**: Most iOS tutorials and documentation use MVVM

### Why Not Other Patterns?

Patterns like **VIPER**, **TCA (The Composable Architecture)**, and **Clean Architecture** are powerful but add complexity that isn't appropriate for a starter template. MVVM provides the right balance of structure and simplicity -- you can always evolve toward more sophisticated patterns as your app grows.

### The Rule

**Views don't talk to storage directly.** Always go through a ViewModel:

```
View → ViewModel → Storage (UserDefaults / Firestore)
```

---

## Modern Patterns (Phase 1 Migration)

The following patterns were established during the Phase 1 modernization of the codebase. All new code should follow these patterns.

### @Observable Migration

ViewModels use the `@Observable` macro (iOS 17+) instead of the legacy `ObservableObject` protocol. This provides fine-grained observation -- SwiftUI only re-renders views when the specific properties they read change, rather than when any `@Published` property changes.

**Pattern:**

```swift
@Observable @MainActor final class SomeViewModel {
    // Plain properties instead of @Published
    var items: [Item] = []
    var isLoading = false

    // Non-UI properties that should not trigger observation
    @ObservationIgnored private let storageKey = "items"
}
```

**View-side changes:**

- Replace `@StateObject` with `@State`
- Replace `@ObservedObject` with a plain `let` binding
- Replace `@EnvironmentObject` with `@Environment`

### Protocol-Based Services

Every service has a protocol defined in `ios/Sources/Protocols/`. This enables dependency injection for testing and decouples ViewModels from concrete implementations.

**Why:** Singletons with `.shared` make unit testing difficult because you cannot substitute mock implementations. Protocols solve this by defining a contract that both the real service and test mocks conform to.

**Pattern:**

```swift
// Protocol definition
@MainActor protocol AuthManaging {
    var isAuthenticated: Bool { get }
    func signIn() async throws
    func signOut() async throws
}

// Concrete implementation
@Observable @MainActor final class AuthManager: AuthManaging { ... }

// Injection via SwiftUI environment
extension EnvironmentValues {
    var authManager: any AuthManaging { ... }
}
```

### NavigationStack with Typed Routes

All navigation uses `NavigationStack(path:)` with typed route enums defined in `AppRouter.swift`. This replaces the older `NavigationView` and `NavigationLink(destination:)` pattern.

**Why:** Typed routes provide compile-time safety for navigation, enable deep linking, and allow programmatic navigation from ViewModels.

**Pattern:**

```swift
// Route definition
enum AppRoute: Hashable {
    case libraryDetail(LibraryEntry)
    case settings
    case streakDetail
}

// Usage in views
NavigationLink(value: AppRoute.libraryDetail(entry)) {
    LibraryEntryRow(entry: entry)
}

// Programmatic navigation
router.path.append(AppRoute.settings)
```

### Centralized Error Handling

All errors flow through a centralized `ErrorHandler` that presents errors to users via a consistent UI. The `AppError` enum conforms to `LocalizedError` for user-facing messages.

**Pattern:**

```swift
// Define domain-specific errors
enum AppError: LocalizedError {
    case networkUnavailable
    case authenticationFailed(String)

    var errorDescription: String? {
        switch self {
        case .networkUnavailable: return "No internet connection."
        case .authenticationFailed(let reason): return "Sign-in failed: \(reason)"
        }
    }
}

// Apply at app root
ContentView()
    .withErrorHandling()
```

### Constants via Enums

All UserDefaults keys and analytics event names are defined as static constants in dedicated enums. No raw strings for storage keys or event names.

**Why:** Raw strings are error-prone -- typos cause silent bugs. Centralizing constants enables autocompletion, find-all-references, and compile-time validation.

**Pattern:**

```swift
enum StorageKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let streakData = "streakData"
    static let appGroupSuite = "group.com.yourcompany.myapp.widgets"
}

enum AnalyticsEvents {
    static let screenView = "screen_view"
    static let streakCompleted = "streak_completed"
    static let paywallShown = "paywall_shown"
}
```

### Feature Flags via #if canImport()

Optional SDK dependencies use compile-time `#if canImport()` guards so the app builds with or without them. Runtime flags in `AppConfiguration` control whether enabled features are active.

**Pattern:**

```swift
#if canImport(RevenueCat)
import RevenueCat
#endif

func configurePurchases() {
    #if canImport(RevenueCat)
    guard AppConfiguration.useRevenueCat else { return }
    Purchases.configure(withAPIKey: AppConfiguration.revenueCatAPIKey)
    #endif
}
```

---

## Folder Structure

Each feature follows this pattern:

```
Sources/
├── YourFeature/
│   ├── Models/           # Data structures (Codable structs)
│   ├── ViewModels/       # State + business logic (@Observable classes)
│   └── Views/            # SwiftUI views
├── Intents/              # App Intents for Siri and Shortcuts
├── LiveActivity/         # Live Activity and Dynamic Island views
├── Notifications/        # Push notification scheduling and handling
├── Navigation/           # AppRouter, route enums, deep linking
├── Protocols/            # Service protocols for dependency injection
```

### Canonical Example: Library/

The `Library/` folder is the most complete example. Reference it when creating new features:

```
Library/
├── Models/
│   └── LibraryModel.swift      # LibraryEntry, LibraryIndex structs
├── ViewModels/
│   └── LibraryViewModel.swift  # Fetching, filtering, caching logic
├── Views/
│   ├── LibraryView.swift       # Main list view
│   ├── LibraryDetailView.swift # Article detail view
│   └── LibraryEntryRow.swift   # List row component
└── Cache/
    └── LibraryCacheManager.swift  # Local caching
```

---

## Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         SwiftUI View                            │
│                  @State var viewModel (owned)                   │
│                  let viewModel (passed in)                      │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                  @Observable ViewModel                          │
│              Plain stored properties                            │
│         Business logic, data transformation                     │
└─────────────────────────┬───────────────────────────────────────┘
                          │
          ┌───────────────┴───────────────┐
          ▼                               ▼
┌─────────────────────┐       ┌─────────────────────────────────┐
│   Local Storage     │       │      FirestoreManager           │
│   (UserDefaults)    │       │   (when useFirebase = true)     │
└─────────────────────┘       └─────────────────────────────────┘
```

### Read Flow

1. View observes `@Observable` ViewModel properties (fine-grained tracking)
2. ViewModel fetches from local storage first (cache)
3. If Firebase enabled, ViewModel also fetches from Firestore
4. ViewModel updates its plain stored properties
5. SwiftUI re-renders only views that read the changed properties

### Write Flow

1. View calls ViewModel method (e.g., `save()`)
2. ViewModel writes to local storage immediately
3. If Firebase enabled, ViewModel also writes to Firestore
4. ViewModel updates its plain stored properties

---

## Adding a New Feature

### Step 1: Create Folder Structure

```bash
mkdir -p Sources/YourFeature/{Models,ViewModels,Views}
```

### Step 2: Define Your Model

```swift
// Sources/YourFeature/Models/YourModel.swift

import Foundation

struct YourItem: Codable, Identifiable {
    let id: String
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date

    init(id: String = UUID().uuidString, title: String, content: String) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
```

### Step 3: Create the ViewModel

```swift
// Sources/YourFeature/ViewModels/YourViewModel.swift

import Foundation
import SwiftUI

@Observable @MainActor final class YourViewModel {

    // MARK: - State (UI binds to these -- plain properties, no @Published needed)
    var items: [YourItem] = []
    var isLoading = false
    var errorMessage: String?

    // MARK: - Dependencies (excluded from observation)
    @ObservationIgnored private let storageKey = "your_items"

    // MARK: - Singleton (if needed app-wide)
    static let shared = YourViewModel()

    // MARK: - Initialization
    init() {
        loadFromLocal()
    }

    // MARK: - Public Methods (called by Views)

    func create(title: String, content: String) {
        let item = YourItem(title: title, content: content)
        items.append(item)
        saveToLocal()
        syncToFirestoreIfEnabled()
    }

    func update(_ item: YourItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        var updated = item
        updated.updatedAt = Date()
        items[index] = updated
        saveToLocal()
        syncToFirestoreIfEnabled()
    }

    func delete(_ item: YourItem) {
        items.removeAll { $0.id == item.id }
        saveToLocal()
        deleteFromFirestoreIfEnabled(item.id)
    }

    // MARK: - Private Methods (internal logic)

    private func loadFromLocal() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([YourItem].self, from: data) else {
            return
        }
        items = decoded
    }

    private func saveToLocal() {
        guard let encoded = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }

    private func syncToFirestoreIfEnabled() {
        #if canImport(Firebase)
        guard AppConfiguration.useFirebase else { return }
        // FirestoreManager.shared.saveItems(items)
        #endif
    }

    private func deleteFromFirestoreIfEnabled(_ id: String) {
        #if canImport(Firebase)
        guard AppConfiguration.useFirebase else { return }
        // FirestoreManager.shared.deleteItem(id)
        #endif
    }
}
```

### Step 4: Create the Views

```swift
// Sources/YourFeature/Views/YourListView.swift

import SwiftUI

struct YourListView: View {
    @State private var viewModel = YourViewModel.shared

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.items) { item in
                    NavigationLink(value: AppRoute.yourDetail(item)) {
                        YourRowView(item: item)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Your Feature")
            .toolbar {
                Button(action: addItem) {
                    Image(systemName: "plus")
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                // Handle navigation via AppRouter
            }
        }
        .task {
            Analytics.trackScreenView("YourListView")
        }
    }

    private func addItem() {
        viewModel.create(title: "New Item", content: "")
    }

    private func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            viewModel.delete(viewModel.items[index])
        }
    }
}
```

### Step 5: Add to Navigation

In `MainTabView.swift`, add your new tab:

```swift
case 3:
    YourListView()

// And the tab icon:
TabBarIcon(
    selectedTab: $selectedTab,
    assignedTab: 3,
    systemIconName: "star.fill",
    tabName: "Your Tab",
    color: AppColors.accent
)
```

---

## Key Singletons

| Singleton                  | Purpose              | File                           |
| -------------------------- | -------------------- | ------------------------------ |
| `AuthManager.shared`       | Authentication state | `Auth/AuthManager.swift`       |
| `PaywallManager.shared`    | Subscription state   | `Paywall/PaywallManager.swift` |
| `SettingsViewModel.shared` | User settings        | `User/SettingsViewModel.swift` |
| `StreakViewModel.shared`   | Streak display       | `Streak/StreakViewModel.swift` |
| `FirestoreManager.shared`  | Firestore operations | `User/FirestoreManager.swift`  |

---

## Conditional Firebase Pattern

Always guard Firebase code with both compile-time and runtime checks:

```swift
#if canImport(Firebase)
import Firebase
#endif

class SomeManager {
    func doSomething() {
        // Local logic always runs
        saveLocally()

        // Firebase logic only when enabled
        #if canImport(Firebase)
        if AppConfiguration.useFirebase {
            saveToFirestore()
        }
        #endif
    }
}
```

---

## Analytics Pattern

Track screen views and events consistently:

```swift
// Screen views - in .task modifier
.task {
    Analytics.trackScreenView("ScreenName")
}

// Events - on user actions
Button("Subscribe") {
    Analytics.track(event: "subscribe_tapped", parameters: ["source": "settings"])
    PaywallManager.shared.triggerPaywall()
}
```

---

## Naming Conventions

| Type       | Convention          | Example                                 |
| ---------- | ------------------- | --------------------------------------- |
| Models     | Singular noun       | `LibraryEntry`, `StreakData`            |
| ViewModels | Feature + ViewModel | `LibraryViewModel`, `SettingsViewModel` |
| Views      | Descriptive + View  | `LibraryView`, `StreakBadgeView`        |
| Managers   | Feature + Manager   | `PaywallManager`, `CacheManager`        |
| Providers  | Feature + ViewModel | `StreakViewModel`                       |

---

## For AI Assistants

When generating code for this project:

1. **Follow the Library/ pattern** - It's the canonical example
2. **Use @Observable** - With `@MainActor final class` ViewModels (see Phase 1 patterns above)
3. **Use @State for owned ViewModels** - Replace `@StateObject` with `@State`; use plain `let` for passed-in ViewModels
4. **Use NavigationStack** - With typed `AppRoute` enums and `NavigationLink(value:)`; never use `NavigationView` or `NavigationLink(destination:)`
5. **Use protocol-based services** - Define protocols in `Protocols/`; inject via SwiftUI environment
6. **Use centralized error handling** - Flow errors through `AppError` and `.withErrorHandling()`
7. **Use constants enums** - `StorageKeys`, `AnalyticsEvents` -- no raw strings for keys
8. **Always add Analytics** - `Analytics.trackScreenView()` in Views
9. **Check AppConfiguration** - Respect feature flags
10. **Use #if canImport()** - For optional dependencies
11. **Prefer UserDefaults** - For simple local storage
12. **Follow existing naming** - Match the conventions above

Current feature areas to be aware of (Phases 4-7):

- **Onboarding**: 5-screen redesign with personalization (goal, frequency) and notification priming
- **Custom Paywall**: 3-tier paywall with A/B variant support (`PaywallConfiguration`)
- **Streak Freeze/Repair**: Users can freeze streaks or repair broken ones (premium feature)
- **Notifications**: `NotificationManager` handles streak reminders, milestone alerts, content updates
- **App Intents**: Siri Shortcuts via `Intents/` for quick streak check and logging
- **Live Activity**: Dynamic Island and Lock Screen live activities for active streaks
- **iPad**: `NavigationSplitView` for sidebar-based layouts, `AppCommands` for keyboard shortcuts
- **Accessibility**: `AccessibilityIdentifiers.swift` for UI testing; always add `.accessibilityIdentifier()`

When modifying existing features:

1. Read the existing code first
2. Match the existing style exactly
3. Don't refactor unrelated code
4. Keep changes minimal and focused

---

## Common Patterns

### Loading State

```swift
// Plain properties in @Observable class -- no @Published needed
var isLoading = false
var errorMessage: String?

func fetch() {
    isLoading = true
    errorMessage = nil

    // ... async work ...

    isLoading = false
}
```

### List with Search

```swift
// Plain properties in @Observable class -- no @Published needed
var items: [Item] = []
var searchText = ""

var filteredItems: [Item] {
    if searchText.isEmpty {
        return items
    }
    return items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
}
```

### Offline-First Save

```swift
func save(_ item: Item) {
    // 1. Save locally first (instant)
    saveToLocal(item)

    // 2. Sync to cloud (eventual)
    #if canImport(Firebase)
    if AppConfiguration.useFirebase {
        Task {
            try? await saveToFirestore(item)
        }
    }
    #endif
}
```
