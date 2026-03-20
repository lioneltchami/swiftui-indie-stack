//
//  OnboardingState.swift
//  MyApp
//
//  Observable state model for the multi-screen onboarding flow.
//  Tracks current step, personalization answers, and notification preferences.
//

import Foundation

@Observable @MainActor
final class OnboardingState {
    var currentStep: Int = 0
    var totalSteps: Int = 5
    var selectedGoal: String?
    var selectedFrequency: GoalFrequency = .daily
    var notificationsAccepted: Bool = false
    var hasCompletedOnboarding: Bool = false

    enum GoalFrequency: String, CaseIterable, Identifiable {
        case daily = "Every day"
        case weekdays = "Weekdays only"
        case threePerWeek = "3 times per week"

        var id: String { rawValue }

        var localizedTitle: String {
            switch self {
            case .daily:
                return String(localized: "frequency_daily")
            case .weekdays:
                return String(localized: "frequency_weekdays")
            case .threePerWeek:
                return String(localized: "frequency_three_per_week")
            }
        }

        var icon: String {
            switch self {
            case .daily: return "calendar"
            case .weekdays: return "briefcase.fill"
            case .threePerWeek: return "3.circle.fill"
            }
        }

        var description: String {
            switch self {
            case .daily:
                return String(localized: "frequency_daily_desc")
            case .weekdays:
                return String(localized: "frequency_weekdays_desc")
            case .threePerWeek:
                return String(localized: "frequency_three_per_week_desc")
            }
        }
    }

    var progress: Double {
        Double(currentStep) / Double(totalSteps)
    }
}
