//
//  AnalyticsServiceProtocol.swift
//  MyApp
//
//  Protocol abstraction for Analytics.
//  Provides an instance-based protocol so the static Analytics facade
//  can delegate to a conforming instance, enabling test doubles.
//  No TelemetryDeck or third-party analytics SDK types are exposed.
//

import Foundation

protocol AnalyticsServiceProtocol {

    // MARK: - Core Tracking

    /// Track an analytics event with optional parameters
    /// - Parameters:
    ///   - event: Event name (e.g., "view.HomeScreen", "button.subscribe")
    ///   - parameters: Additional key-value parameters for the event
    func track(event: String, parameters: [String: Any])

    // MARK: - Convenience Methods

    /// Track a screen view event
    /// - Parameter screenName: Name of the screen being viewed
    func trackScreenView(_ screenName: String)

    /// Track a button tap event
    /// - Parameters:
    ///   - buttonName: Name of the button tapped
    ///   - screenName: Optional screen where the tap occurred
    func trackButtonTap(_ buttonName: String, on screenName: String?)

    /// Track a feature usage event
    /// - Parameter featureName: Name of the feature used
    func trackFeatureUsed(_ featureName: String)

    /// Track an error event
    /// - Parameters:
    ///   - errorType: Type/category of the error
    ///   - message: Optional human-readable error message
    func trackError(_ errorType: String, message: String?)

    /// Track an onboarding step
    /// - Parameters:
    ///   - step: Step number in the onboarding flow
    ///   - stepName: Name of the onboarding step
    func trackOnboardingStep(_ step: Int, stepName: String)

    /// Track a subscription-related event
    /// - Parameter action: The subscription action (e.g., "started", "cancelled")
    func trackSubscription(_ action: String)
}

// MARK: - Default Parameter Values

extension AnalyticsServiceProtocol {

    func track(event: String) {
        track(event: event, parameters: [:])
    }

    func trackButtonTap(_ buttonName: String) {
        trackButtonTap(buttonName, on: nil)
    }

    func trackError(_ errorType: String) {
        trackError(errorType, message: nil)
    }
}
