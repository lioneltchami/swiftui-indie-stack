//
//  AnalyticsEvents.swift
//  MyApp
//
//  Centralized analytics event name constants.
//  All event strings are defined here to ensure consistency across the codebase
//  and to make it easy to audit what is tracked.
//
//  Usage:
//  ```swift
//  Analytics.track(event: AnalyticsEvents.goalCompleted)
//  Analytics.track(event: AnalyticsEvents.screenView("HomeScreen"))
//  ```
//

import Foundation

enum AnalyticsEvents {

    // MARK: - App Lifecycle

    /// App launched (cold start)
    static let appLaunch = "app_launch"

    // MARK: - Goals

    /// User completed their daily goal
    static let goalCompleted = "goal_completed"

    // MARK: - Paywall & Subscription

    /// Paywall was displayed to the user
    static let paywallShown = "paywall_shown"

    /// Onboarding paywall was displayed
    static let paywallOnboardingShown = "paywall_onboarding_shown"

    /// User skipped the onboarding paywall
    static let paywallOnboardingSkipped = "paywall_onboarding_skipped"

    /// User tapped subscribe on the onboarding paywall
    static let paywallOnboardingTapped = "paywall_onboarding_tapped"

    /// User tapped a purchase button on the paywall
    static let paywallPurchaseTapped = "paywall_purchase_tapped"

    /// User has an active subscription
    static let subscriptionActive = "subscription_active"

    /// User restored previous purchases
    static let purchasesRestored = "purchases_restored"

    // MARK: - App Review

    /// App Store review prompt was requested
    static let appReviewRequested = "app_review_requested"

    // MARK: - Streaks

    /// User used a streak freeze
    static let streakFreezeUsed = "streak_freeze_used"

    /// User repaired a broken streak
    static let streakRepaired = "streak_repaired"

    // MARK: - Notifications

    /// User tapped on a push notification to open the app
    static let notificationOpened = "notification.opened"

    /// User responded to notification permission prompt
    static let notificationPermission = "notification_permission"

    // MARK: - Live Activity

    /// A Live Activity session was started
    static let liveActivityStarted = "live_activity_started"

    /// A Live Activity session was ended
    static let liveActivityEnded = "live_activity_ended"

    // MARK: - Library

    /// User viewed a library entry detail page
    static let libraryViewEntry = "library.view.entry"

    // MARK: - Errors

    /// An error occurred (use with type/message parameters)
    static let error = "error"

    // MARK: - Button Taps

    /// A button was tapped (use with button/screen parameters)
    static let buttonTap = "button.tap"

    // MARK: - Dynamic Event Builders

    /// Screen view event. Produces events like "view.HomeScreen", "view.SettingsView".
    /// - Parameter name: The screen name
    /// - Returns: Formatted event string
    static func screenView(_ name: String) -> String {
        "view.\(name)"
    }

    /// Feature usage event. Produces events like "feature.darkMode", "feature.export".
    /// - Parameter name: The feature name
    /// - Returns: Formatted event string
    static func feature(_ name: String) -> String {
        "feature.\(name)"
    }

    /// Subscription lifecycle event. Produces events like "subscription.started", "subscription.cancelled".
    /// - Parameter action: The subscription action
    /// - Returns: Formatted event string
    static func subscription(_ action: String) -> String {
        "subscription.\(action)"
    }

    /// Onboarding step event. Always returns "onboarding.step" -- step number and name
    /// are passed as parameters to `Analytics.trackOnboardingStep`.
    static let onboardingStep = "onboarding.step"
}
