//
//  CheckStreakIntent.swift
//  MyApp
//
//  App Intent for checking the current streak status via Siri or Shortcuts.
//  Returns current streak, at-risk status, and best streak information.
//

import AppIntents

struct CheckStreakIntent: AppIntent {
    static var title: LocalizedStringResource = "Check My Streak"
    static var description: IntentDescription = "Check your current streak status."
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let data = await MainActor.run {
            StreakViewModel.shared.streakData
        }

        if data.currentStreak > 0 {
            if data.isAtRisk {
                let message = String(localized: "intent_streak_at_risk \(data.currentStreak)")
                return .result(dialog: "\(message)")
            }
            let message = String(localized: "intent_streak_status \(data.currentStreak) \(data.bestStreak)")
            return .result(dialog: "\(message)")
        } else {
            let message = String(localized: "intent_no_streak")
            return .result(dialog: "\(message)")
        }
    }
}
