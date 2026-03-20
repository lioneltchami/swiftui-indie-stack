//
//  SubscriptionUpgradeView.swift
//  MyApp
//
//  Shows native StoreKit subscription upgrade options using SubscriptionStoreView.
//  Use this when a monthly subscriber hits a milestone to suggest upgrading to annual.
//
//  This complements the custom paywall (CustomPaywallView) rather than replacing it.
//  The custom paywall handles initial acquisition; this view handles plan changes
//  for existing subscribers using Apple's native upgrade/crossgrade UI.
//
//  Requires iOS 17.0+ for SubscriptionStoreView.
//

import SwiftUI
import StoreKit

/// Shows native StoreKit subscription upgrade options.
/// Present this when a monthly subscriber hits a milestone to suggest annual.
@available(iOS 17.0, *)
struct SubscriptionUpgradeView: View {
    let groupID: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SubscriptionStoreView(groupID: groupID)
            .subscriptionStorePickerItemBackground(.thinMaterial)
            .storeButton(.visible, for: .restorePurchases)
            .subscriptionStoreControlStyle(.prominentPicker)
            .onInAppPurchaseCompletion { product, result in
                switch result {
                case .success(.success(let transaction)):
                    Analytics.track(
                        event: AnalyticsEvents.subscription("upgraded"),
                        parameters: ["product": product.id]
                    )
                    await transaction.finish()
                    dismiss()
                case .success(.pending):
                    // Transaction requires approval (e.g., Ask to Buy)
                    Analytics.track(
                        event: AnalyticsEvents.subscription("upgrade_pending"),
                        parameters: ["product": product.id]
                    )
                case .success(.userCancelled):
                    Analytics.track(
                        event: AnalyticsEvents.subscription("upgrade_cancelled"),
                        parameters: ["product": product.id]
                    )
                case .failure(let error):
                    debugPrint("Upgrade purchase failed: \(error)")
                    Analytics.track(
                        event: AnalyticsEvents.error,
                        parameters: [
                            "type": "subscription_upgrade",
                            "message": error.localizedDescription
                        ]
                    )
                @unknown default:
                    break
                }
            }
    }
}

// MARK: - Convenience Modifier

@available(iOS 17.0, *)
extension View {
    /// Presents the subscription upgrade sheet when the binding is true.
    /// - Parameters:
    ///   - isPresented: Binding controlling sheet presentation
    ///   - groupID: The StoreKit subscription group identifier
    func subscriptionUpgradeSheet(
        isPresented: Binding<Bool>,
        groupID: String
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            SubscriptionUpgradeView(groupID: groupID)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    SubscriptionUpgradeView(groupID: "YOUR_GROUP_ID")
}
#endif
