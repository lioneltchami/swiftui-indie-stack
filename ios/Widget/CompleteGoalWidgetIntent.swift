//
//  CompleteGoalWidgetIntent.swift
//  MyAppWidget
//
//  App Intent for the interactive widget button that marks today's goal as complete.
//  This is a widget-local intent (separate from the main app's CompleteGoalIntent)
//  because the widget target cannot import from Sources/.
//

import AppIntents
import WidgetKit

struct CompleteGoalWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Goal"
    static var description: IntentDescription = "Mark today's goal as complete"

    func perform() async throws -> some IntentResult {
        // Update shared UserDefaults for widget data bridge
        let defaults = UserDefaults(suiteName: "group.com.yourcompany.myapp.widgets")
        // Signal completion - the main app will pick this up
        defaults?.set(Date().timeIntervalSince1970, forKey: "lastGoalCompletionFromWidget")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
