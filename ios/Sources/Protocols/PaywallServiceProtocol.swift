//
//  PaywallServiceProtocol.swift
//  MyApp
//
//  Protocol abstraction for PaywallManager.
//  Uses Swift-native types only -- no RevenueCat imports required.
//  SDK-specific types (e.g., CustomerInfo) stay in the concrete implementation.
//

import Foundation

@MainActor
protocol PaywallServiceProtocol: AnyObject {

    // MARK: - Observable State

    /// Whether the paywall sheet should be presented
    var showPaywall: Bool { get set }

    /// Whether the user has an active subscription
    var isSubscribed: Bool { get }

    // MARK: - Subscription Status

    /// Check if user has an active subscription, updating internal state
    /// - Returns: `true` if the user has at least one active entitlement
    @discardableResult
    func checkSubscriptionStatus() async -> Bool

    /// Check if user has a specific entitlement by identifier
    /// - Parameter identifier: The entitlement identifier to check
    /// - Returns: `true` if the entitlement is active
    func hasEntitlement(_ identifier: String) async -> Bool

    // MARK: - Paywall Display

    /// Show the paywall if the user is not currently subscribed
    func showPaywallIfNeeded()

    /// Trigger paywall display unconditionally
    func triggerPaywall()

    // MARK: - Purchase Restoration

    /// Restore previous purchases
    /// - Throws: If the restore operation fails
    @discardableResult
    func restorePurchases() async throws -> Bool
}
