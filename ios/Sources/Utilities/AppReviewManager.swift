//
//  AppReviewManager.swift
//  MyApp
//
//  Manages App Store review prompts at strategic moments.
//  Follows Apple's best practices for review requests.
//

import StoreKit
@preconcurrency import SwiftUI

/// Manages App Store review requests
///
/// This manager handles requesting app reviews at optimal moments (e.g., after streak achievements).
/// It tracks whether a review has been requested for each threshold to avoid spamming users.
///
/// Usage:
/// ```swift
/// // Check and potentially request review after streak achievement
/// AppReviewManager.shared.requestReviewIfAppropriate(for: streakCount)
/// ```
///
/// The actual review dialog is controlled by Apple's SKStoreReviewController, which may
/// choose not to show the dialog based on its own heuristics (e.g., if shown too recently).
final class AppReviewManager {

    static let shared = AppReviewManager()

    private init() {}

    // MARK: - Public Methods

    // MARK: - Quality Gate Constants

    /// Minimum number of app sessions before requesting a review.
    /// Ensures the user has enough experience with the app to form an opinion.
    private static let minimumSessionCount = 10

    /// Minimum number of days since install before requesting a review.
    /// Prevents asking brand-new users who haven't had time to evaluate the app.
    private static let minimumDaysSinceInstall = 7

    /// Request a review if conditions are met
    ///
    /// Call this when the user achieves a streak milestone. The review will only be requested
    /// if ALL quality gates pass:
    /// - App review is enabled in configuration
    /// - User has reached the streak threshold
    /// - User has not been prompted for this threshold before
    /// - User has completed at least 10 sessions (engagement gate)
    /// - User completed a goal today (positive action gate)
    /// - User installed the app at least 7 days ago (maturity gate)
    ///
    /// These gates ensure we only prompt engaged, satisfied users at moments of achievement,
    /// which maximizes the likelihood of positive reviews.
    ///
    /// - Parameter streakCount: The user's current streak count
    func requestReviewIfAppropriate(for streakCount: Int) {
        guard AppConfiguration.enableAppReview else { return }
        guard streakCount >= AppConfiguration.appReviewStreakThreshold else { return }
        guard !hasRequestedReviewForCurrentThreshold else { return }
        guard hasEnoughSessions else { return }
        guard hasCompletedGoalToday else { return }
        guard hasBeenInstalledLongEnough else { return }

        requestReview()
        markReviewRequested()
    }

    /// Force request a review (use sparingly)
    ///
    /// Bypasses the streak threshold check. Still respects the enableAppReview flag
    /// and won't re-prompt if already prompted for current threshold.
    func requestReviewManually() {
        guard AppConfiguration.enableAppReview else { return }
        guard !hasRequestedReviewForCurrentThreshold else { return }

        requestReview()
        markReviewRequested()
    }

    /// Reset review tracking (useful for testing or after major app updates)
    func resetReviewTracking() {
        UserDefaults.standard.removeObject(forKey: StorageKeys.appReviewRequestedForStreak)
    }

    // MARK: - Private Methods

    /// Whether the user has completed enough sessions to be considered engaged.
    private var hasEnoughSessions: Bool {
        let sessionCount = UserDefaults.standard.integer(forKey: StorageKeys.sessionCount)
        return sessionCount >= Self.minimumSessionCount
    }

    /// Whether the user completed a goal today, indicating a positive moment.
    private var hasCompletedGoalToday: Bool {
        let lastActivityInterval = UserDefaults.standard.double(forKey: StorageKeys.localLastActivityDate)
        guard lastActivityInterval > 0 else { return false }
        let lastActivityDate = Date(timeIntervalSince1970: lastActivityInterval)
        return Calendar.current.isDateInToday(lastActivityDate)
    }

    /// Whether enough days have passed since install for the user to have formed an opinion.
    private var hasBeenInstalledLongEnough: Bool {
        let installInterval = UserDefaults.standard.double(forKey: StorageKeys.appInstallDate)
        guard installInterval > 0 else { return false }
        let installDate = Date(timeIntervalSince1970: installInterval)
        let daysSinceInstall = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
        return daysSinceInstall >= Self.minimumDaysSinceInstall
    }

    private var hasRequestedReviewForCurrentThreshold: Bool {
        let requestedThreshold = UserDefaults.standard.integer(forKey: StorageKeys.appReviewRequestedForStreak)
        return requestedThreshold >= AppConfiguration.appReviewStreakThreshold
    }

    private func markReviewRequested() {
        UserDefaults.standard.set(
            AppConfiguration.appReviewStreakThreshold,
            forKey: StorageKeys.appReviewRequestedForStreak
        )
    }

    private func requestReview() {
        Task { @MainActor in
            // Small delay to ensure we're not interrupting other UI
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {

                // Use modern API on iOS 18+, fallback for iOS 17
                if #available(iOS 18.0, *) {
                    AppStore.requestReview(in: scene)
                } else {
                    SKStoreReviewController.requestReview(in: scene)
                }

                Analytics.track(event: AnalyticsEvents.appReviewRequested, parameters: [
                    "streak_threshold": AppConfiguration.appReviewStreakThreshold,
                    "session_count": UserDefaults.standard.integer(forKey: StorageKeys.sessionCount)
                ])
            }
        }
    }
}
