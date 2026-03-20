//
//  SettingsViewModel.swift
//  MyApp
//
//  Manages user settings with local persistence (UserDefaults).
//  Optionally syncs to Firestore when Firebase is enabled.
//
//  Offline-first: Settings always work locally. Cloud sync is optional.
//

import SwiftUI

@Observable @MainActor
final class SettingsViewModel: SettingsServiceProtocol {

    static let shared = SettingsViewModel()

    @ObservationIgnored private var debounceTimer: Timer?

    // MARK: - App Settings (backed by UserDefaults)

    var showOnboardingOnLaunch: Bool {
        get { UserDefaults.standard.bool(forKey: StorageKeys.showOnboardingOnLaunch) }
        set { UserDefaults.standard.set(newValue, forKey: StorageKeys.showOnboardingOnLaunch) }
    }

    var appearance: Appearance {
        get {
            let rawValue = UserDefaults.standard.string(forKey: StorageKeys.appearance) ?? ""
            return Appearance(rawValue: rawValue) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: StorageKeys.appearance)
        }
    }

    // MARK: - Notification Preferences

    var notificationsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: StorageKeys.notificationsEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: StorageKeys.notificationsEnabled) }
    }

    var streakReminderEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: StorageKeys.streakReminderEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: StorageKeys.streakReminderEnabled) }
    }

    // MARK: - Date Tracking

    @ObservationIgnored private var _appInstallDate: Date?
    @ObservationIgnored private var _lastAppUsageDate: Date?

    var appInstallDate: Date? {
        get {
            if _appInstallDate == nil {
                if let timestamp = UserDefaults.standard.object(forKey: StorageKeys.appInstallDate) as? TimeInterval {
                    _appInstallDate = Date(timeIntervalSince1970: timestamp)
                }
            }
            return _appInstallDate
        }
        set {
            _appInstallDate = newValue
            if let date = newValue {
                UserDefaults.standard.set(date.timeIntervalSince1970, forKey: StorageKeys.appInstallDate)
            } else {
                UserDefaults.standard.removeObject(forKey: StorageKeys.appInstallDate)
            }
        }
    }

    var lastAppUsageDate: Date? {
        get {
            if _lastAppUsageDate == nil {
                if let timestamp = UserDefaults.standard.object(forKey: StorageKeys.lastAppUsageDate) as? TimeInterval {
                    _lastAppUsageDate = Date(timeIntervalSince1970: timestamp)
                }
            }
            return _lastAppUsageDate
        }
        set {
            _lastAppUsageDate = newValue
            if let date = newValue {
                UserDefaults.standard.set(date.timeIntervalSince1970, forKey: StorageKeys.lastAppUsageDate)
            } else {
                UserDefaults.standard.removeObject(forKey: StorageKeys.lastAppUsageDate)
            }
        }
    }

    // MARK: - Initialization

    private init() {
        // Set install date if not already set (first launch)
        if appInstallDate == nil {
            appInstallDate = Date()
        }
    }

    // MARK: - Settings Persistence

    /// Flag settings for Firestore update with debouncing
    func flagSettingsForUpdate() {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            self?.persistSettings()
        }
    }

    /// Get all settings as a dictionary for Firestore
    func getSettings() -> [String: Any] {
        [
            "showOnboardingOnLaunch": showOnboardingOnLaunch,
            "appearance": appearance.rawValue,
            "notificationsEnabled": notificationsEnabled,
            "streakReminderEnabled": streakReminderEnabled,
            "appInstallDate": appInstallDate?.timeIntervalSince1970 as Any,
            "lastAppUsageDate": lastAppUsageDate?.timeIntervalSince1970 as Any
        ]
    }

    /// Save settings to Firestore
    private func persistSettings() {
        let settingsData = getSettings()
        FirestoreManager.shared.saveUserSettings(settingsData: settingsData)
    }

    /// Restore settings from Firestore data
    func restoreSettings(newSettings: [String: Any]) {
        showOnboardingOnLaunch = newSettings["showOnboardingOnLaunch"] as? Bool ?? false
        appearance = Appearance(rawValue: newSettings["appearance"] as? String ?? "") ?? .system
        notificationsEnabled = newSettings["notificationsEnabled"] as? Bool ?? false
        streakReminderEnabled = newSettings["streakReminderEnabled"] as? Bool ?? true

        if let installTimestamp = newSettings["appInstallDate"] as? TimeInterval {
            appInstallDate = Date(timeIntervalSince1970: installTimestamp)
        }
        if let usageTimestamp = newSettings["lastAppUsageDate"] as? TimeInterval {
            lastAppUsageDate = Date(timeIntervalSince1970: usageTimestamp)
        }
    }

    // MARK: - App Usage Tracking

    /// Mark app usage for activity tracking
    func markAppUsage() {
        let now = Date()

        var shouldUpdateFirestore = false
        if let lastUsage = lastAppUsageDate {
            if !Calendar.current.isDate(lastUsage, inSameDayAs: now) {
                shouldUpdateFirestore = true
            }
        } else {
            shouldUpdateFirestore = true
        }

        lastAppUsageDate = now

        if shouldUpdateFirestore {
            // Log activity for backend streak calculation
            FirestoreManager.shared.logActivity(type: "app_open")
            flagSettingsForUpdate()
        }
    }

    /// Days since app was installed
    var daysSinceInstall: Int {
        guard let installDate = appInstallDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
    }

}

// MARK: - Appearance Enum

enum Appearance: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }
}
