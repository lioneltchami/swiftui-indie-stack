//
//  AppReviewManagerTests.swift
//  MyAppTests
//
//  Tests for AppReviewManager quality gates that control when
//  app review prompts are shown.
//

import Testing
import Foundation
@testable import MyApp

@Suite("AppReviewManager Tests")
@MainActor
struct AppReviewManagerTests {

    /// Helper to set up UserDefaults for testing review conditions.
    /// Resets all relevant keys before each test configuration.
    private func resetReviewDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: StorageKeys.appReviewRequestedForStreak)
        defaults.removeObject(forKey: StorageKeys.sessionCount)
        defaults.removeObject(forKey: StorageKeys.localLastActivityDate)
        defaults.removeObject(forKey: StorageKeys.appInstallDate)
    }

    /// Configures UserDefaults so all quality gates pass:
    /// session count >= 10, goal completed today, installed 7+ days ago.
    private func configureAllGatesPassing() {
        let defaults = UserDefaults.standard
        defaults.set(15, forKey: StorageKeys.sessionCount)
        defaults.set(Date().timeIntervalSince1970, forKey: StorageKeys.localLastActivityDate)
        let eightDaysAgo = Calendar.current.date(byAdding: .day, value: -8, to: Date())!
        defaults.set(eightDaysAgo.timeIntervalSince1970, forKey: StorageKeys.appInstallDate)
    }

    // MARK: - Streak Threshold

    @Test("requestReviewIfAppropriate respects streak threshold")
    func respectsStreakThreshold() {
        resetReviewDefaults()
        configureAllGatesPassing()

        let manager = AppReviewManager.shared
        manager.resetReviewTracking()

        // Streak below threshold should not mark review as requested
        manager.requestReviewIfAppropriate(for: AppConfiguration.appReviewStreakThreshold - 1)

        // If review was NOT triggered, the tracking key should still be unset
        let requestedThreshold = UserDefaults.standard.integer(forKey: StorageKeys.appReviewRequestedForStreak)
        #expect(requestedThreshold < AppConfiguration.appReviewStreakThreshold,
                "Review should not be requested when streak is below threshold")
    }

    // MARK: - Session Count Gate

    @Test("requestReviewIfAppropriate requires session count >= 10")
    func requiresMinimumSessionCount() {
        resetReviewDefaults()

        let defaults = UserDefaults.standard
        // Set session count below minimum (10)
        defaults.set(5, forKey: StorageKeys.sessionCount)
        // Set other gates to passing
        defaults.set(Date().timeIntervalSince1970, forKey: StorageKeys.localLastActivityDate)
        let eightDaysAgo = Calendar.current.date(byAdding: .day, value: -8, to: Date())!
        defaults.set(eightDaysAgo.timeIntervalSince1970, forKey: StorageKeys.appInstallDate)

        let manager = AppReviewManager.shared
        manager.resetReviewTracking()

        // Even with a high streak, low session count should block the review
        manager.requestReviewIfAppropriate(for: AppConfiguration.appReviewStreakThreshold + 10)

        let requestedThreshold = UserDefaults.standard.integer(forKey: StorageKeys.appReviewRequestedForStreak)
        #expect(requestedThreshold < AppConfiguration.appReviewStreakThreshold,
                "Review should not be requested when session count is below 10")
    }

    // MARK: - Goal Completed Today Gate

    @Test("requestReviewIfAppropriate requires goal completed today")
    func requiresGoalCompletedToday() {
        resetReviewDefaults()

        let defaults = UserDefaults.standard
        defaults.set(15, forKey: StorageKeys.sessionCount)
        // Set last activity to yesterday (goal NOT completed today)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        defaults.set(yesterday.timeIntervalSince1970, forKey: StorageKeys.localLastActivityDate)
        let eightDaysAgo = Calendar.current.date(byAdding: .day, value: -8, to: Date())!
        defaults.set(eightDaysAgo.timeIntervalSince1970, forKey: StorageKeys.appInstallDate)

        let manager = AppReviewManager.shared
        manager.resetReviewTracking()

        manager.requestReviewIfAppropriate(for: AppConfiguration.appReviewStreakThreshold + 10)

        let requestedThreshold = UserDefaults.standard.integer(forKey: StorageKeys.appReviewRequestedForStreak)
        #expect(requestedThreshold < AppConfiguration.appReviewStreakThreshold,
                "Review should not be requested when goal was not completed today")
    }
}
