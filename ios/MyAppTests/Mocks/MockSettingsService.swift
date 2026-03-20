import Foundation
@testable import MyApp

@MainActor
final class MockSettingsService: SettingsServiceProtocol {

    // MARK: - Configurable State (In-Memory Storage)

    var showOnboardingOnLaunch: Bool = true
    var appearance: Appearance = .system
    var notificationsEnabled: Bool = false
    var streakReminderEnabled: Bool = false
    var appInstallDate: Date? = nil
    var lastAppUsageDate: Date? = nil

    var daysSinceInstall: Int {
        guard let installDate = appInstallDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
    }

    // MARK: - Call Tracking

    var flagSettingsForUpdateCallCount = 0
    var getSettingsCallCount = 0
    var restoreSettingsCallCount = 0
    var restoreSettingsLastInput: [String: Any]?
    var markAppUsageCallCount = 0

    // MARK: - Protocol Conformance

    func flagSettingsForUpdate() {
        flagSettingsForUpdateCallCount += 1
    }

    func getSettings() -> [String: Any] {
        getSettingsCallCount += 1
        return [
            "showOnboardingOnLaunch": showOnboardingOnLaunch,
            "appearance": appearance.rawValue,
            "notificationsEnabled": notificationsEnabled,
            "streakReminderEnabled": streakReminderEnabled
        ]
    }

    func restoreSettings(newSettings: [String: Any]) {
        restoreSettingsCallCount += 1
        restoreSettingsLastInput = newSettings
        if let onboarding = newSettings["showOnboardingOnLaunch"] as? Bool {
            showOnboardingOnLaunch = onboarding
        }
        if let rawAppearance = newSettings["appearance"] as? String,
           let restored = Appearance(rawValue: rawAppearance) {
            appearance = restored
        }
        if let notifications = newSettings["notificationsEnabled"] as? Bool {
            notificationsEnabled = notifications
        }
        if let streakReminder = newSettings["streakReminderEnabled"] as? Bool {
            streakReminderEnabled = streakReminder
        }
    }

    func markAppUsage() {
        markAppUsageCallCount += 1
        lastAppUsageDate = Date()
    }
}
