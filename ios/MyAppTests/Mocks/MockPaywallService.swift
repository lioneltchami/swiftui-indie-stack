import Foundation
@testable import MyApp

@MainActor
final class MockPaywallService: PaywallServiceProtocol {

    // MARK: - Configurable State

    var showPaywall: Bool = false
    var isSubscribed: Bool = false

    // MARK: - Configurable Behavior

    var checkSubscriptionStatusResult: Bool = false
    var hasEntitlementResult: Bool = false
    var restorePurchasesResult: Result<Bool, Error> = .success(true)

    // MARK: - Call Tracking

    var checkSubscriptionStatusCallCount = 0
    var hasEntitlementCallCount = 0
    var hasEntitlementLastIdentifier: String?
    var showPaywallIfNeededCallCount = 0
    var triggerPaywallCallCount = 0
    var restorePurchasesCallCount = 0

    // MARK: - Protocol Conformance

    @discardableResult
    func checkSubscriptionStatus() async -> Bool {
        checkSubscriptionStatusCallCount += 1
        isSubscribed = checkSubscriptionStatusResult
        return checkSubscriptionStatusResult
    }

    func hasEntitlement(_ identifier: String) async -> Bool {
        hasEntitlementCallCount += 1
        hasEntitlementLastIdentifier = identifier
        return hasEntitlementResult
    }

    func showPaywallIfNeeded() {
        showPaywallIfNeededCallCount += 1
        if !isSubscribed {
            showPaywall = true
        }
    }

    func triggerPaywall() {
        triggerPaywallCallCount += 1
        showPaywall = true
    }

    @discardableResult
    func restorePurchases() async throws -> Bool {
        restorePurchasesCallCount += 1
        switch restorePurchasesResult {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
