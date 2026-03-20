//
//  AppTips.swift
//  MyApp
//
//  TipKit tips for contextual user guidance.
//  Tips appear based on user behavior rules (e.g., after N streak completions).
//  Requires iOS 17+ (TipKit availability).
//

import SwiftUI
import TipKit

// MARK: - Streak Freeze Tip

/// Tip: Streak freeze protection -- shown after 3 streak completions
struct StreakFreezeTip: Tip {
    static let streakCompletionCount = Event(id: "streakCompletion")

    var title: Text { Text(String(localized: "tip_freeze_title")) }
    var message: Text? { Text(String(localized: "tip_freeze_message")) }
    var image: Image? { Image(systemName: "snowflake") }

    var rules: [Rule] {
        #Rule(Self.streakCompletionCount) { $0.donations.count >= 3 }
    }
}

// MARK: - Milestone Share Tip

/// Tip: Share milestone achievements
struct MilestoneShareTip: Tip {
    var title: Text { Text(String(localized: "tip_milestone_title")) }
    var message: Text? { Text(String(localized: "tip_milestone_message")) }
    var image: Image? { Image(systemName: "square.and.arrow.up") }
}

// MARK: - Siri Shortcut Tip

/// Tip: Use Siri to log habits -- shown after 5 manual completions
struct SiriShortcutTip: Tip {
    static let manualLogCount = Event(id: "manualLog")

    var title: Text { Text(String(localized: "tip_siri_title")) }
    var message: Text? { Text(String(localized: "tip_siri_message")) }
    var image: Image? { Image(systemName: "mic.fill") }

    var rules: [Rule] {
        #Rule(Self.manualLogCount) { $0.donations.count >= 5 }
    }
}

// MARK: - Streak Repair Tip

/// Tip: Repair broken streaks (premium feature)
struct StreakRepairTip: Tip {
    var title: Text { Text(String(localized: "tip_repair_title")) }
    var message: Text? { Text(String(localized: "tip_repair_message")) }
    var image: Image? { Image(systemName: "arrow.counterclockwise") }
}
