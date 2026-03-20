//
//  AppShortcuts.swift
//  MyApp
//
//  Defines Siri phrases and shortcuts for App Intents.
//  Registers CompleteGoalIntent and CheckStreakIntent with the system.
//

import AppIntents

struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CompleteGoalIntent(),
            phrases: [
                "Complete my goal in \(.applicationName)",
                "Mark goal done in \(.applicationName)",
                "Log activity in \(.applicationName)"
            ],
            shortTitle: "Complete Goal",
            systemImageName: "checkmark.circle.fill"
        )
        AppShortcut(
            intent: CheckStreakIntent(),
            phrases: [
                "Check my streak in \(.applicationName)",
                "How's my streak in \(.applicationName)",
                "What's my streak in \(.applicationName)"
            ],
            shortTitle: "Check Streak",
            systemImageName: "flame.fill"
        )
    }
}
