//
//  AppCommands.swift
//  MyApp
//
//  Mac Catalyst menu bar commands with keyboard shortcuts for cross-platform support.
//

import SwiftUI

struct AppCommands: Commands {
    var body: some Commands {
        // Replace default New Window command
        CommandGroup(replacing: .newItem) {
            // No new item action needed
        }

        // Custom commands
        CommandMenu("Library") {
            Button("Refresh Library") {
                NotificationCenter.default.post(
                    name: .refreshLibrary,
                    object: nil
                )
            }
            .keyboardShortcut("r", modifiers: .command)

            Divider()

            Button("Search Library") {
                NotificationCenter.default.post(
                    name: .searchLibrary,
                    object: nil
                )
            }
            .keyboardShortcut("f", modifiers: .command)
        }

        CommandMenu("Streak") {
            Button("Complete Goal") {
                NotificationCenter.default.post(
                    name: .completeGoal,
                    object: nil
                )
            }
            .keyboardShortcut("d", modifiers: .command)
        }

        // Settings shortcut (standard macOS convention)
        CommandGroup(after: .appSettings) {
            Button("Settings...") {
                NotificationCenter.default.post(
                    name: .openSettings,
                    object: nil
                )
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}

// MARK: - Notification Names for Cross-View Communication

extension Notification.Name {
    static let refreshLibrary = Notification.Name("refreshLibrary")
    static let searchLibrary = Notification.Name("searchLibrary")
    static let completeGoal = Notification.Name("completeGoal")
    static let openSettings = Notification.Name("openSettings")
}
