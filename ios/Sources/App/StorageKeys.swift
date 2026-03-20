//
//  StorageKeys.swift
//  MyApp
//
//  Centralized UserDefaults key constants.
//  All raw key strings are defined here to prevent typos and enable refactoring.
//
//  Usage:
//  ```swift
//  UserDefaults.standard.string(forKey: StorageKeys.localUserId)
//  @AppStorage(StorageKeys.appearance) var appearance: Appearance = .system
//  ```
//

import Foundation

enum StorageKeys {

    // MARK: - Auth

    /// Local device-based user ID for non-Firebase mode
    static let localUserId = "localUserId"

    // MARK: - Onboarding

    /// Whether the user has completed onboarding
    static let isOnboardingDone = "isOnboardingDone"

    /// Whether to show onboarding again on next launch
    static let showOnboardingOnLaunch = "showOnboardingOnLaunch"

    /// User's selected goal from onboarding personalization
    static let selectedGoal = "selectedGoal"

    /// User's selected frequency from onboarding personalization
    static let selectedFrequency = "selectedFrequency"

    // MARK: - Session Tracking

    /// Total number of app sessions (for app review gating)
    static let sessionCount = "sessionCount"

    // MARK: - Appearance

    /// User's selected appearance theme (system/light/dark)
    static let appearance = "appearance"

    // MARK: - Notifications

    /// Whether push notifications are enabled
    static let notificationsEnabled = "notificationsEnabled"

    /// Whether streak reminder notifications are enabled
    static let streakReminderEnabled = "streakReminderEnabled"

    // MARK: - Streak (Local Mode)

    /// Current streak count (local mode)
    static let localCurrentStreak = "localCurrentStreak"

    /// Best streak count ever achieved (local mode)
    static let localBestStreak = "localBestStreak"

    /// Last activity date as TimeInterval (local mode)
    static let localLastActivityDate = "localLastActivityDate"

    /// Streak start date as TimeInterval (local mode)
    static let localStreakStartDate = "localStreakStartDate"

    /// Array of active day timestamps (local mode)
    static let localActiveDays = "localActiveDays"

    /// Number of streak freezes available (local mode)
    static let localFreezesAvailable = "localFreezesAvailable"

    /// Whether a streak freeze is currently active (local mode)
    static let localFreezeActive = "localFreezeActive"

    /// Number of freezes used in the current billing period (local mode)
    static let localFreezesUsedThisPeriod = "localFreezesUsedThisPeriod"

    /// Whether a broken streak can be repaired (local mode)
    static let localStreakRepairable = "localStreakRepairable"

    /// The streak count before the last break, used for repair (local mode)
    static let localLastStreakBeforeBreak = "localLastStreakBeforeBreak"

    /// Date when monthly freeze allocation was last reset (local mode)
    static let localFreezeResetDate = "localFreezeResetDate"

    // MARK: - Date Tracking

    /// App install date as TimeInterval
    static let appInstallDate = "appInstallDate"

    /// Last app usage date as TimeInterval
    static let lastAppUsageDate = "lastAppUsageDate"

    // MARK: - App Review

    /// Streak threshold at which an app review was last requested
    static let appReviewRequestedForStreak = "appReviewRequestedForStreak"

    // MARK: - Widget

    /// Encoded streak data shared with widget extension via App Groups
    static let widgetStreakData = "widgetStreakData"

    // MARK: - Library Cache

    /// Cached library index JSON data
    static let libraryIndex = "com.myapp.library.index"

    /// Date when library index was last updated
    static let libraryIndexLastUpdated = "com.myapp.library.indexLastUpdated"

    /// Cache key prefix for individual library entry content
    private static let libraryContentPrefix = "com.myapp.library.content."

    /// Generate cache key for a specific library entry's content
    /// - Parameters:
    ///   - id: The library entry identifier
    ///   - version: The content version string (stable across app launches, unlike hashValue)
    /// - Returns: The UserDefaults key for the cached content
    static func libraryContent(id: String, version: String) -> String {
        "\(libraryContentPrefix)\(id).\(version)"
    }

    /// Cache key prefix for clearing all library content entries
    static var libraryContentCachePrefix: String {
        libraryContentPrefix
    }

    // MARK: - App Group

    /// App Group suite name for sharing data between the main app and widget extension.
    /// Must match the App Group identifier in both targets' Signing & Capabilities.
    static let appGroupSuite = "group.com.yourcompany.myapp.widgets"
}
