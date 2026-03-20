//
//  StreakViewModel.swift
//  MyApp
//
//  Provides streak data to the UI.
//
//  Two modes based on AppConfiguration.useFirebase:
//
//  Firebase Mode (useFirebase = true):
//  - All streak logic runs on the backend (Firebase Functions)
//  - This class simply displays data from Firestore
//  - Backend calculates streaks, sends reminders, applies freezes
//
//  Local Mode (useFirebase = false):
//  - Simple local streak tracking using UserDefaults
//  - Basic streak calculation (daily activity)
//  - No freezes, no reminders, no cloud sync
//

import Foundation
import SwiftUI
import WidgetKit

#if canImport(Firebase)
import FirebaseFirestore
#endif

/// Provides streak data to SwiftUI views
@Observable @MainActor
final class StreakViewModel: StreakServiceProtocol {

    // MARK: - Singleton

    static let shared = StreakViewModel()

    // MARK: - State

    var streakData: StreakData = .empty
    var isLoading: Bool = false

    // MARK: - Dependencies

    #if canImport(Firebase)
    @ObservationIgnored private var listener: ListenerRegistration?
    @ObservationIgnored private var db: Firestore?
    #endif

    // MARK: - Initialization

    private init() {
        #if canImport(Firebase)
        if AppConfiguration.useFirebase {
            db = Firestore.firestore()
        }
        #endif

        // Load local data on init (used in local mode or as fallback)
        loadLocalData()
    }

    // MARK: - Firebase Listener (Cloud Mode)

    /// Start listening to streak updates from Firestore
    func startListening(userId: String) {
        guard AppConfiguration.useFirebase else {
            // In local mode, just load from UserDefaults
            loadLocalData()
            return
        }

        #if canImport(Firebase)
        stopListening()

        guard let db = db else { return }

        isLoading = true

        listener = db.collection("users").document(userId)
            .addSnapshotListener { @Sendable [weak self] documentSnapshot, error in
                Task { @MainActor in
                    guard let self = self else { return }

                    self.isLoading = false

                    if let error = error {
                        debugPrint("Error listening to streak updates: \(error)")
                        return
                    }

                    guard let data = documentSnapshot?.data(),
                          let streakDict = data["streak"] as? [String: Any] else {
                        return
                    }

                    self.updateFromFirestore(streakDict)
                }
            }
        #endif
    }

    /// Stop listening to Firestore updates
    func stopListening() {
        #if canImport(Firebase)
        listener?.remove()
        listener = nil
        #endif
    }

    /// Update local streak data from Firestore dictionary
    func updateFromFirestore(_ data: [String: Any]) {
        let currentStreak = data["currentStreak"] as? Int ?? 0
        let bestStreak = data["bestStreak"] as? Int ?? 0
        let isAtRisk = data["isAtRisk"] as? Bool ?? false
        let freezesAvailable = data["freezesAvailable"] as? Int ?? 0
        let freezeActive = data["freezeActive"] as? Bool ?? false
        let freezesUsedThisPeriod = data["freezesUsedThisPeriod"] as? Int ?? 0
        let streakRepairable = data["streakRepairable"] as? Bool ?? false
        let lastStreakBeforeBreak = data["lastStreakBeforeBreak"] as? Int

        var lastActivityDate: Date?
        var streakStartDate: Date?
        var activeDays: [Date] = []

        #if canImport(Firebase)
        if let timestamp = data["lastActivityDate"] as? Timestamp {
            lastActivityDate = timestamp.dateValue()
        }

        if let timestamp = data["streakStartDate"] as? Timestamp {
            streakStartDate = timestamp.dateValue()
        }

        if let timestamps = data["activeDays"] as? [Timestamp] {
            activeDays = timestamps.map { $0.dateValue() }
        }
        #endif

        self.streakData = StreakData(
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            lastActivityDate: lastActivityDate,
            streakStartDate: streakStartDate,
            isAtRisk: isAtRisk,
            freezesAvailable: freezesAvailable,
            freezeActive: freezeActive,
            activeDays: activeDays,
            freezesUsedThisPeriod: freezesUsedThisPeriod,
            streakRepairable: streakRepairable,
            lastStreakBeforeBreak: lastStreakBeforeBreak
        )

        // Sync to widget
        WidgetHelper.updateWidget(with: self.streakData)

        // Check for app review prompt on streak milestone
        AppReviewManager.shared.requestReviewIfAppropriate(for: currentStreak)
    }

    // MARK: - Local Mode

    /// Load streak data from UserDefaults (local mode)
    private func loadLocalData() {
        let defaults = UserDefaults.standard

        let currentStreak = defaults.integer(forKey: StorageKeys.localCurrentStreak)
        let bestStreak = defaults.integer(forKey: StorageKeys.localBestStreak)
        let freezesAvailable = defaults.integer(forKey: StorageKeys.localFreezesAvailable)
        let freezeActive = defaults.bool(forKey: StorageKeys.localFreezeActive)
        let freezesUsedThisPeriod = defaults.integer(forKey: StorageKeys.localFreezesUsedThisPeriod)
        let streakRepairable = defaults.bool(forKey: StorageKeys.localStreakRepairable)

        var lastStreakBeforeBreak: Int?
        if defaults.object(forKey: StorageKeys.localLastStreakBeforeBreak) != nil {
            lastStreakBeforeBreak = defaults.integer(forKey: StorageKeys.localLastStreakBeforeBreak)
        }

        var lastActivityDate: Date?
        if let timestamp = defaults.object(forKey: StorageKeys.localLastActivityDate) as? TimeInterval {
            lastActivityDate = Date(timeIntervalSince1970: timestamp)
        }

        var streakStartDate: Date?
        if let timestamp = defaults.object(forKey: StorageKeys.localStreakStartDate) as? TimeInterval {
            streakStartDate = Date(timeIntervalSince1970: timestamp)
        }

        var activeDays: [Date] = []
        if let timestamps = defaults.array(forKey: StorageKeys.localActiveDays) as? [TimeInterval] {
            activeDays = timestamps.map { Date(timeIntervalSince1970: $0) }
        }

        // Reset monthly freeze allocation if needed
        let monthlyResolvedFreezes = resetMonthlyFreezesIfNeeded(
            currentFreezes: freezesAvailable,
            freezesUsed: freezesUsedThisPeriod
        )

        // Check if streak is at risk (last activity was yesterday, need to complete today)
        var isAtRisk = false
        var resolvedCurrentStreak = currentStreak
        var resolvedFreezeActive = freezeActive
        var resolvedFreezesAvailable = monthlyResolvedFreezes
        var resolvedFreezesUsed = freezesUsedThisPeriod
        var resolvedStreakRepairable = streakRepairable
        var resolvedLastStreakBeforeBreak = lastStreakBeforeBreak

        if let last = lastActivityDate {
            let calendar = Calendar.current
            if calendar.isDate(last, inSameDayAs: Date()) {
                // Completed today -- not at risk
                isAtRisk = false
            } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()),
                      calendar.isDate(last, inSameDayAs: yesterday) {
                // Last activity was yesterday -- at risk, user needs to complete today
                isAtRisk = true
            } else {
                // More than 1 day missed -- streak is broken, not "at risk"
                isAtRisk = false

                // Auto-freeze: if exactly one day was missed and freezes are available,
                // consume a freeze to preserve the streak
                if resolvedFreezesAvailable > 0 && resolvedCurrentStreak > 0 {
                    let daysSinceLast = calendar.dateComponents([.day], from: calendar.startOfDay(for: last), to: calendar.startOfDay(for: Date())).day ?? 0
                    if daysSinceLast == 2 {
                        // Exactly one missed day -- auto-freeze preserves streak
                        resolvedFreezesAvailable -= 1
                        resolvedFreezesUsed += 1
                        resolvedFreezeActive = true
                        // Streak is preserved, mark as at risk since they still need to complete today
                        isAtRisk = true
                    }
                }
            }
        }

        self.streakData = StreakData(
            currentStreak: resolvedCurrentStreak,
            bestStreak: bestStreak,
            lastActivityDate: lastActivityDate,
            streakStartDate: streakStartDate,
            isAtRisk: isAtRisk,
            freezesAvailable: resolvedFreezesAvailable,
            freezeActive: resolvedFreezeActive,
            activeDays: activeDays,
            freezesUsedThisPeriod: resolvedFreezesUsed,
            streakRepairable: resolvedStreakRepairable,
            lastStreakBeforeBreak: resolvedLastStreakBeforeBreak
        )

        // Persist auto-freeze changes if any were made
        if resolvedFreezeActive != freezeActive || resolvedFreezesAvailable != monthlyResolvedFreezes {
            saveLocalData()
        }

        // Sync to widget
        WidgetHelper.updateWidget(with: self.streakData)

        // Schedule streak reminder if streak is at risk and user has a streak worth protecting
        if isAtRisk && resolvedCurrentStreak > 0 {
            NotificationScheduler.scheduleStreakReminder(streakCount: resolvedCurrentStreak)
        }
    }

    /// Save streak data to UserDefaults (local mode)
    private func saveLocalData() {
        let defaults = UserDefaults.standard

        defaults.set(streakData.currentStreak, forKey: StorageKeys.localCurrentStreak)
        defaults.set(streakData.bestStreak, forKey: StorageKeys.localBestStreak)
        defaults.set(streakData.freezesAvailable, forKey: StorageKeys.localFreezesAvailable)
        defaults.set(streakData.freezeActive, forKey: StorageKeys.localFreezeActive)
        defaults.set(streakData.freezesUsedThisPeriod, forKey: StorageKeys.localFreezesUsedThisPeriod)
        defaults.set(streakData.streakRepairable, forKey: StorageKeys.localStreakRepairable)

        if let lastStreakBeforeBreak = streakData.lastStreakBeforeBreak {
            defaults.set(lastStreakBeforeBreak, forKey: StorageKeys.localLastStreakBeforeBreak)
        } else {
            defaults.removeObject(forKey: StorageKeys.localLastStreakBeforeBreak)
        }

        if let date = streakData.lastActivityDate {
            defaults.set(date.timeIntervalSince1970, forKey: StorageKeys.localLastActivityDate)
        }

        if let date = streakData.streakStartDate {
            defaults.set(date.timeIntervalSince1970, forKey: StorageKeys.localStreakStartDate)
        }

        let timestamps = streakData.activeDays.map { $0.timeIntervalSince1970 }
        defaults.set(timestamps, forKey: StorageKeys.localActiveDays)
    }

    /// Record activity locally (for local mode only)
    func recordLocalActivity() {
        guard !AppConfiguration.useFirebase else {
            // In Firebase mode, activity is logged via FirestoreManager
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Check if already logged today
        if let lastActivity = streakData.lastActivityDate,
           calendar.isDate(lastActivity, inSameDayAs: today) {
            return // Already logged today
        }

        var newCurrentStreak = streakData.currentStreak
        var newStreakStart = streakData.streakStartDate
        var newFreezeActive = false
        var newFreezesAvailable = streakData.freezesAvailable
        var newFreezesUsed = streakData.freezesUsedThisPeriod
        var newStreakRepairable = false
        var newLastStreakBeforeBreak: Int? = streakData.lastStreakBeforeBreak

        if let lastActivity = streakData.lastActivityDate {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

            if calendar.isDate(lastActivity, inSameDayAs: yesterday) {
                // Continue streak
                newCurrentStreak += 1
            } else if streakData.freezeActive {
                // Freeze was auto-applied in loadLocalData(), streak preserved -- continue it
                newCurrentStreak += 1
                newFreezeActive = false
            } else {
                // Streak broken, save previous streak for repair option
                if newCurrentStreak >= 3 {
                    newStreakRepairable = true
                    newLastStreakBeforeBreak = newCurrentStreak
                }
                newCurrentStreak = 1
                newStreakStart = today
            }
        } else {
            // First activity ever
            newCurrentStreak = 1
            newStreakStart = today
        }

        let newBestStreak = max(streakData.bestStreak, newCurrentStreak)

        // Update active days (keep last 31 days)
        var newActiveDays = streakData.activeDays.filter {
            calendar.dateComponents([.day], from: $0, to: today).day ?? 32 < 31
        }
        newActiveDays.append(today)

        // Clear repair option once user has a new streak going
        if newCurrentStreak >= 3 {
            newStreakRepairable = false
            newLastStreakBeforeBreak = nil
        }

        self.streakData = StreakData(
            currentStreak: newCurrentStreak,
            bestStreak: newBestStreak,
            lastActivityDate: today,
            streakStartDate: newStreakStart,
            isAtRisk: false,
            freezesAvailable: newFreezesAvailable,
            freezeActive: newFreezeActive,
            activeDays: newActiveDays,
            freezesUsedThisPeriod: newFreezesUsed,
            streakRepairable: newStreakRepairable,
            lastStreakBeforeBreak: newLastStreakBeforeBreak
        )
        self.saveLocalData()

        // Sync to widget
        WidgetHelper.updateWidget(with: self.streakData)

        // Goal completed for today -- cancel any pending streak reminders
        NotificationScheduler.cancelStreakReminders()

        // Schedule milestone congratulations if applicable
        if self.streakData.isMilestone {
            NotificationScheduler.scheduleMilestoneCongrats(milestone: newCurrentStreak)
        }

        // Check for app review prompt on streak milestone
        AppReviewManager.shared.requestReviewIfAppropriate(for: newCurrentStreak)
    }

    // MARK: - Freeze & Repair (Local Mode)

    /// Manually use a streak freeze to protect against a missed day.
    /// Decrements freezesAvailable and marks freeze as active.
    func useFreeze() {
        guard !AppConfiguration.useFirebase else { return }
        guard streakData.freezesAvailable > 0 else { return }
        guard streakData.isAtRisk else { return }

        self.streakData = StreakData(
            currentStreak: streakData.currentStreak,
            bestStreak: streakData.bestStreak,
            lastActivityDate: streakData.lastActivityDate,
            streakStartDate: streakData.streakStartDate,
            isAtRisk: false,
            freezesAvailable: streakData.freezesAvailable - 1,
            freezeActive: true,
            activeDays: streakData.activeDays,
            freezesUsedThisPeriod: streakData.freezesUsedThisPeriod + 1,
            streakRepairable: streakData.streakRepairable,
            lastStreakBeforeBreak: streakData.lastStreakBeforeBreak
        )
        saveLocalData()
        WidgetHelper.updateWidget(with: self.streakData)
    }

    /// Repair a broken streak by restoring the previous streak count.
    /// This is a premium-only feature. The caller must verify premium status before invoking.
    func repairStreak() {
        guard !AppConfiguration.useFirebase else { return }
        guard streakData.streakRepairable else { return }
        guard let previousStreak = streakData.lastStreakBeforeBreak, previousStreak > 0 else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        self.streakData = StreakData(
            currentStreak: previousStreak,
            bestStreak: max(streakData.bestStreak, previousStreak),
            lastActivityDate: today,
            streakStartDate: streakData.streakStartDate,
            isAtRisk: false,
            freezesAvailable: streakData.freezesAvailable,
            freezeActive: false,
            activeDays: streakData.activeDays,
            freezesUsedThisPeriod: streakData.freezesUsedThisPeriod,
            streakRepairable: false,
            lastStreakBeforeBreak: nil
        )
        saveLocalData()
        WidgetHelper.updateWidget(with: self.streakData)
    }

    /// Reset monthly freeze allocation if the calendar month has changed.
    /// Free users get 1 freeze per month; premium users get unlimited (handled via freeze purchase).
    private func resetMonthlyFreezesIfNeeded(currentFreezes: Int, freezesUsed: Int) -> Int {
        let defaults = UserDefaults.standard
        let calendar = Calendar.current
        let now = Date()

        if let lastResetTimestamp = defaults.object(forKey: StorageKeys.localFreezeResetDate) as? TimeInterval {
            let lastReset = Date(timeIntervalSince1970: lastResetTimestamp)
            if !calendar.isDate(lastReset, equalTo: now, toGranularity: .month) {
                // New month -- reset freeze allocation
                defaults.set(now.timeIntervalSince1970, forKey: StorageKeys.localFreezeResetDate)
                defaults.set(0, forKey: StorageKeys.localFreezesUsedThisPeriod)
                // Grant 1 free freeze for the new month
                let newFreezes = max(currentFreezes, 1)
                defaults.set(newFreezes, forKey: StorageKeys.localFreezesAvailable)
                return newFreezes
            }
        } else {
            // First time -- initialize with 1 free freeze
            defaults.set(now.timeIntervalSince1970, forKey: StorageKeys.localFreezeResetDate)
            if currentFreezes == 0 && freezesUsed == 0 {
                defaults.set(1, forKey: StorageKeys.localFreezesAvailable)
                return 1
            }
        }

        return currentFreezes
    }

    // MARK: - Computed Properties

    /// Whether the user has an active streak
    var hasStreak: Bool {
        streakData.currentStreak > 0
    }

    /// Whether this is a milestone streak (7, 30, 100, 365 days)
    var isMilestone: Bool {
        streakData.isMilestone
    }

    /// Formatted streak text
    var streakText: String {
        if streakData.currentStreak == 1 {
            return String(localized: "streak_text_one_day")
        } else {
            return String(localized: "streak_text_days \(streakData.currentStreak)")
        }
    }

    /// Whether streaks are enabled.
    /// Marked nonisolated because AppConfiguration is a static enum (Sendable),
    /// safe to read from any actor context.
    nonisolated var isEnabled: Bool {
        AppConfiguration.enableStreaks
    }
}
