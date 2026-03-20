//
//  AppDependencies.swift
//  MyApp
//
//  Extends EnvironmentValues with app-level dependencies using the
//  @Entry macro (iOS 17+). This allows any view to access shared
//  services via @Environment without manual EnvironmentKey boilerplate.
//
//  Usage:
//  ```swift
//  // Injection at root:
//  ContentView()
//      .environment(errorHandler)
//
//  // Consumption in any view:
//  @Environment(ErrorHandler.self) var errorHandler
//  ```
//

import SwiftUI

extension EnvironmentValues {
    /// Centralized error handler for presenting alerts and toasts.
    @Entry var errorHandler: ErrorHandler = ErrorHandler()
}
