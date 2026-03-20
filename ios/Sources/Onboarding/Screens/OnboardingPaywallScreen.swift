//
//  OnboardingPaywallScreen.swift
//  MyApp
//
//  Onboarding Screen 5: Post-onboarding paywall wrapper.
//  Presents the paywall as the final onboarding step with a "Not now" skip option.
//  This is the highest-conversion moment for showing a paywall.
//
//  Integrates with CustomPaywallView for the post-onboarding paywall experience.
//  Uses PaywallManager to route between custom and RevenueCat native paywalls.
//

import SwiftUI

struct OnboardingPaywallScreen: View {
    let state: OnboardingState
    let onComplete: () -> Void

    var body: some View {
        CustomPaywallView(config: PaywallManager.shared.currentPaywallConfig)
            .overlay(alignment: .bottom) {
                // Skip option (App Store requirement: paywall must be dismissable)
                Button(String(localized: "onboarding_paywall_skip")) {
                    Analytics.track(
                        event: AnalyticsEvents.paywallOnboardingSkipped,
                        parameters: ["source": "onboarding"]
                    )
                    onComplete()
                }
                .tertiaryStyle()
                .accessibilityLabel(String(localized: "accessibility_paywall_skip"))
                .padding(.bottom, 8)
            }
            .task {
                Analytics.trackOnboardingStep(4, stepName: "paywall")
                Analytics.track(
                    event: AnalyticsEvents.paywallOnboardingShown,
                    parameters: ["source": "onboarding"]
                )
            }
    }
}

// MARK: - Paywall Feature Row

private struct PaywallFeatureRow: View {
    let icon: String
    let text: String

    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 24

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: iconSize * 0.7))
                .foregroundStyle(AppColors.primary)
                .frame(width: iconSize, height: iconSize)
                .accessibilityHidden(true)

            Text(text)
                .font(AppFonts.body)
                .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    OnboardingPaywallScreen(state: OnboardingState(), onComplete: {})
}
