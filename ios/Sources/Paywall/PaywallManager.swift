//
//  PaywallManager.swift
//  MyApp
//
//  Manages RevenueCat paywall display and subscription status.
//  Supports both RevenueCat's native paywall UI and a custom paywall view
//  with A/B testing variant support. Toggle between them using
//  `AppConfiguration.useCustomPaywall`.
//

import SwiftUI

#if canImport(RevenueCat)
import RevenueCat
import RevenueCatUI
#endif

@Observable @MainActor
final class PaywallManager: PaywallServiceProtocol {

    static let shared = PaywallManager()

    var showPaywall = false
    var isSubscribed = false
    #if canImport(RevenueCat)
    var customerInfo: CustomerInfo?
    #endif

    /// Whether to use the custom paywall instead of RevenueCat's default UI.
    /// Reads from `AppConfiguration.useCustomPaywall`.
    var useCustomPaywall: Bool = AppConfiguration.useCustomPaywall

    /// The current paywall A/B test variant.
    /// Reads from `AppConfiguration.paywallVariant`.
    var paywallVariant: String = AppConfiguration.paywallVariant

    /// Whether the custom paywall sheet should be presented.
    var showCustomPaywall = false

    @ObservationIgnored @LoggerWrapper(category: "PaywallManager")
    private var log

    private init() {
        // Don't access Purchases.shared here - it may not be configured yet.
        // Customer info will be fetched when configure() is called after
        // Purchases.configure(withAPIKey:) in MyApp.swift.
    }

    /// Call after Purchases.configure(withAPIKey:) to safely fetch initial customer info.
    func configure() {
        #if canImport(RevenueCat)
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            self?.handleCustomerInfoUpdate(customerInfo)
        }
        #endif
    }

    // MARK: - Subscription Status

    /// Check if user has an active subscription
    @discardableResult
    func checkSubscriptionStatus() async -> Bool {
        #if canImport(RevenueCat)
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            let hasActiveEntitlement = !customerInfo.entitlements.active.isEmpty

            self.isSubscribed = hasActiveEntitlement
            self.customerInfo = customerInfo

            return hasActiveEntitlement
        } catch {
            log.error("Error checking subscription status: \(error)")
            return false
        }
        #else
        return false
        #endif
    }

    /// Check if user has a specific entitlement
    func hasEntitlement(_ identifier: String) async -> Bool {
        #if canImport(RevenueCat)
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            return customerInfo.entitlements[identifier]?.isActive == true
        } catch {
            log.error("Error checking entitlement: \(error)")
            return false
        }
        #else
        return false
        #endif
    }

    // MARK: - Paywall Display

    /// Show paywall if user is not subscribed.
    /// Automatically routes to either the custom paywall or RevenueCat's native paywall
    /// based on `useCustomPaywall`.
    func showPaywallIfNeeded() {
        Task {
            let isSubscribed = await checkSubscriptionStatus()
            if !isSubscribed {
                presentPaywall()
            }
        }
    }

    /// Trigger paywall display unconditionally.
    /// Routes to custom or RevenueCat paywall based on configuration.
    func triggerPaywall() {
        log.info("Showing paywall (custom: \(useCustomPaywall), variant: \(paywallVariant))")
        presentPaywall()
    }

    /// Present the appropriate paywall based on configuration.
    private func presentPaywall() {
        if useCustomPaywall {
            showCustomPaywall = true
            Analytics.track(
                event: AnalyticsEvents.paywallShown,
                parameters: [
                    "type": "custom",
                    "variant": paywallVariant
                ]
            )
        } else {
            showPaywall = true
            Analytics.track(
                event: AnalyticsEvents.paywallShown,
                parameters: ["type": "revenuecat"]
            )
        }
    }

    /// Returns the `PaywallConfiguration` for the current variant.
    var currentPaywallConfig: PaywallConfiguration {
        PaywallConfiguration.config(for: paywallVariant)
    }

    // MARK: - Customer Info Handling

    #if canImport(RevenueCat)
    private func handleCustomerInfoUpdate(_ customerInfo: CustomerInfo?) {
        guard let customerInfo = customerInfo else { return }

        self.customerInfo = customerInfo
        self.isSubscribed = !customerInfo.entitlements.active.isEmpty

        if self.isSubscribed {
            Analytics.track(event: AnalyticsEvents.subscriptionActive)
        }
    }
    #endif

    // MARK: - Restore Purchases

    /// Restore previous purchases
    /// - Returns: `true` if the user has an active subscription after restore
    @discardableResult
    func restorePurchases() async throws -> Bool {
        #if canImport(RevenueCat)
        let customerInfo = try await Purchases.shared.restorePurchases()
        handleCustomerInfoUpdate(customerInfo)
        Analytics.track(event: AnalyticsEvents.purchasesRestored)
        return isSubscribed
        #else
        return false
        #endif
    }
}

// MARK: - Paywall View Modifier

/// View modifier that presents either the custom paywall or RevenueCat's default paywall
/// based on `AppConfiguration.useCustomPaywall`.
struct PaywallPresenter: ViewModifier {
    var paywallManager = PaywallManager.shared

    func body(content: Content) -> some View {
        @Bindable var paywallManager = paywallManager
        content
            #if canImport(RevenueCat)
            // RevenueCat native paywall
            .sheet(isPresented: $paywallManager.showPaywall) {
                PaywallView()
                    .onRestoreCompleted { customerInfo in
                        debugPrint("Restore completed: \(customerInfo.entitlements.active)")
                    }
            }
            #endif
            // Custom paywall
            .sheet(isPresented: $paywallManager.showCustomPaywall) {
                CustomPaywallView(config: paywallManager.currentPaywallConfig)
            }
    }
}

extension View {
    /// Add paywall presentation capability to any view.
    /// Supports both RevenueCat native paywall and custom paywall
    /// based on `AppConfiguration.useCustomPaywall`.
    func withPaywall() -> some View {
        modifier(PaywallPresenter())
    }
}
