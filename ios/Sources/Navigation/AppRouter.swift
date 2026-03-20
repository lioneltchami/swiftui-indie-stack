//
//  AppRouter.swift
//  MyApp
//
//  Centralized navigation router with type-safe route enums for NavigationStack.
//

import SwiftUI

// MARK: - Route Enums

/// Routes available from the Home tab
enum HomeRoute: Hashable {
    case streakDetail
}

/// Routes available from the Library tab
enum LibraryRoute: Hashable {
    case articleDetail(LibraryEntry)
}

/// Routes available from the Settings tab
enum SettingsRoute: Hashable {
    case signIn
}

// MARK: - App Router

/// Centralized navigation state for all tabs.
/// Use `@Environment(AppRouter.self)` in views that need programmatic navigation.
@Observable
@MainActor
final class AppRouter {

    // MARK: - Navigation Paths

    var homePath: [HomeRoute] = []
    var libraryPath: [LibraryRoute] = []
    var settingsPath: [SettingsRoute] = []

    // MARK: - Navigation Helpers

    func navigateHome(to route: HomeRoute) {
        homePath.append(route)
    }

    func navigateLibrary(to route: LibraryRoute) {
        libraryPath.append(route)
    }

    func navigateSettings(to route: SettingsRoute) {
        settingsPath.append(route)
    }

    func popToRootHome() {
        homePath.removeAll()
    }

    func popToRootLibrary() {
        libraryPath.removeAll()
    }

    func popToRootSettings() {
        settingsPath.removeAll()
    }
}
