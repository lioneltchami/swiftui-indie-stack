//
//  CustomPaywallView.swift
//  MyApp
//
//  Custom 3-tier paywall with annual anchoring, social proof,
//  feature comparison, and A/B test variant support.
//  Works alongside RevenueCat's native paywall, not replacing it.
//
//  The custom paywall UI calls RevenueCat's purchase APIs under the hood.
//  Subscription management, receipt validation, and entitlement checking
//  still go through RevenueCat.
//

import SwiftUI

struct CustomPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let config: PaywallConfiguration

    @State private var selectedPlan: PaywallConfiguration.Plan = .yearly
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Close button
                closeButton

                // Hero section
                heroSection

                // Urgency text (variant-specific)
                if let urgencyText = config.urgencyText {
                    urgencyBanner(urgencyText)
                }

                // Pricing tiers
                pricingSection

                // Feature comparison
                FeatureComparisonView()
                    .padding(.horizontal, 16)

                // Social proof
                SocialProofSection(config: config)
                    .padding(.horizontal, 16)

                // CTA button
                ctaButton

                // Restore + Terms
                legalSection
            }
        }
        .interactiveDismissDisabled(isPurchasing)
        .alert(
            String(localized: "paywall_error_title"),
            isPresented: $showError
        ) {
            Button(String(localized: "paywall_error_dismiss")) {}
        } message: {
            Text(errorMessage)
        }
        .task {
            Analytics.track(
                event: AnalyticsEvents.paywallShown,
                parameters: [
                    "variant": config.variant.rawValue,
                    "source": "custom_paywall"
                ]
            )
        }
    }

    // MARK: - Close Button

    private var closeButton: some View {
        HStack {
            Spacer()
            Button {
                Analytics.track(
                    event: "paywall_dismissed",
                    parameters: ["variant": config.variant.rawValue]
                )
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .minimumTouchTarget()
            .accessibilityLabel(String(localized: "paywall_close"))
            .accessibilityIdentifier(AccessibilityID.Paywall.closeButton)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 12) {
            // Premium icon
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.premium)
                .accessibilityHidden(true)

            Text(config.headline)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text(config.subheadline)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Urgency Banner

    @ViewBuilder
    private func urgencyBanner(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .foregroundColor(.white)
                .font(.subheadline)
            Text(text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.accent)
        )
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Pricing Section

    private var pricingSection: some View {
        VStack(spacing: 12) {
            ForEach(PaywallConfiguration.Plan.allCases, id: \.self) { plan in
                PricingTierCard(
                    plan: plan,
                    isSelected: selectedPlan == plan,
                    isRecommended: plan == .yearly
                ) {
                    withAnimation(
                        reduceMotion
                            ? .none
                            : .spring(response: 0.3, dampingFraction: 0.7)
                    ) {
                        selectedPlan = plan
                    }
                    Analytics.track(
                        event: "paywall_plan_selected",
                        parameters: ["plan": plan.rawValue]
                    )
                }
                .accessibilityIdentifier(AccessibilityID.Paywall.planCard(plan.rawValue))
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Button {
            purchaseSelectedPlan()
        } label: {
            HStack(spacing: 8) {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(selectedPlan.ctaText)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppColors.primary)
            )
        }
        .disabled(isPurchasing)
        .padding(.horizontal, 24)
        .accessibilityLabel(selectedPlan.ctaText)
        .accessibilityHint(String(localized: "paywall_cta_hint"))
        .accessibilityIdentifier(AccessibilityID.Paywall.subscribeButton)
    }

    // MARK: - Legal Section

    private var legalSection: some View {
        VStack(spacing: 8) {
            Button(String(localized: "paywall_restore")) {
                Task {
                    do {
                        try await PaywallManager.shared.restorePurchases()
                        dismiss()
                    } catch {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            .minimumTouchTarget()
            .accessibilityIdentifier(AccessibilityID.Paywall.restoreButton)

            HStack(spacing: 4) {
                Link(
                    String(localized: "paywall_terms"),
                    destination: URL(string: AppConfiguration.termsOfServiceURL)!
                )
                Text("|").foregroundColor(.secondary)
                Link(
                    String(localized: "paywall_privacy"),
                    destination: URL(string: AppConfiguration.privacyPolicyURL)!
                )
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.bottom, 24)
    }

    // MARK: - Purchase

    private func purchaseSelectedPlan() {
        guard !isPurchasing else { return }
        isPurchasing = true

        Analytics.track(
            event: AnalyticsEvents.paywallPurchaseTapped,
            parameters: [
                "plan": selectedPlan.rawValue,
                "variant": config.variant.rawValue
            ]
        )

        // Dismiss the custom paywall and present RevenueCat's native
        // paywall which handles the full purchase flow, receipt
        // validation, and entitlement granting.
        dismiss()
        PaywallManager.shared.triggerPaywall()
    }
}

// MARK: - Preview

#Preview("Default Variant") {
    CustomPaywallView(config: .defaultConfig)
}

#Preview("Urgency Variant") {
    CustomPaywallView(config: .urgencyConfig)
}

#Preview("Dark Mode") {
    CustomPaywallView(config: .defaultConfig)
        .preferredColorScheme(.dark)
}
