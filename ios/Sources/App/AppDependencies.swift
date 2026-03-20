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

// Note: ErrorHandler is injected via type-based .environment(errorHandler) in MyApp.swift
// and consumed via @Environment(ErrorHandler.self). The @Entry macro creates a separate
// keypath-based channel (@Environment(\.errorHandler)) which is not used.
// Removed @Entry declaration to avoid confusion between the two injection channels.
