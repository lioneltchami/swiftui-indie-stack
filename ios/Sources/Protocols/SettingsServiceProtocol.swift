//
//  SettingsServiceProtocol.swift
//  MyApp
//
//  Protocol abstraction for SettingsViewModel.
//  Captures the public interface for user settings management
//  with local persistence and optional Firestore sync.
//

import Foundation

@MainActor
protocol SettingsServiceProtocol: AnyObject {

    // MARK: - App Settings

    /// Whether to show onboarding on next launch
    var showOnboardingOnLaunch: Bool { get set }

    /// Current appearance preference (system, light, dark)
    var appearance: Appearance { get set }

    // MARK: - Notification Preferences

    /// Whether notifications are enabled
    var notificationsEnabled: Bool { get set }

    /// Whether streak reminder notifications are enabled
    var streakReminderEnabled: Bool { get set }

    // MARK: - Date Tracking

    /// Date the app was first installed
    var appInstallDate: Date? { get set }

    /// Date the app was last used
    var lastAppUsageDate: Date? { get set }

    /// Number of days since the app was installed
    var daysSinceInstall: Int { get }

    // MARK: - Settings Persistence

    /// Flag settings for debounced Firestore update
    func flagSettingsForUpdate()

    /// Get all settings as a dictionary (for Firestore sync)
    func getSettings() -> [String: Any]

    /// Restore settings from a dictionary (e.g., from Firestore)
    func restoreSettings(newSettings: [String: Any])

    // MARK: - App Usage

    /// Mark app usage for activity tracking
    func markAppUsage()
}
