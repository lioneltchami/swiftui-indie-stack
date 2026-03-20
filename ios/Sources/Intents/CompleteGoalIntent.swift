//
//  CompleteGoalIntent.swift
//  MyApp
//
//  App Intent for completing the daily goal via Siri or Shortcuts.
//  Records local activity and returns the updated streak count.
//

import AppIntents

struct CompleteGoalIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete My Goal"
    static var description: IntentDescription = "Mark today's goal as complete and update your streak."
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let streak = await MainActor.run {
            StreakViewModel.shared.recordLocalActivity()
            return StreakViewModel.shared.streakData.currentStreak
        }
        let message = String(localized: "intent_complete_goal_response \(streak)")
        return .result(dialog: "\(message)")
    }
}
