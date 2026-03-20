//
//  ValueHookScreen.swift
//  MyApp
//
//  Onboarding Screen 1: Value proposition hook.
//  Communicates the app's core value within 7 seconds using a mascot,
//  bold headline, and 3 key benefits.
//

import SwiftUI

struct ValueHookScreen: View {
    let state: OnboardingState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 120
    @ScaledMetric(relativeTo: .body) private var benefitIconSize: CGFloat = 28

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Animated mascot/icon
            Image("Mascot")
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .shadow(radius: 8)
                .accessibilityLabel(String(localized: "accessibility_app_mascot"))

            VStack(spacing: 16) {
                Text(String(localized: "onboarding_hook_title"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(String(localized: "onboarding_hook_subtitle"))
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Key benefits (3 bullet points)
            VStack(alignment: .leading, spacing: 16) {
                BenefitRow(
                    icon: "flame.fill",
                    color: .orange,
                    text: String(localized: "onboarding_benefit_1"),
                    iconSize: benefitIconSize
                )
                BenefitRow(
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue,
                    text: String(localized: "onboarding_benefit_2"),
                    iconSize: benefitIconSize
                )
                BenefitRow(
                    icon: "bell.badge.fill",
                    color: .purple,
                    text: String(localized: "onboarding_benefit_3"),
                    iconSize: benefitIconSize
                )
            }
            .padding(.horizontal, 40)

            Spacer()

            Button(String(localized: "onboarding_continue")) {
                if reduceMotion {
                    state.currentStep = 1
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        state.currentStep = 1
                    }
                }
            }
            .primaryStyle()
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
            .accessibilityLabel(String(localized: "accessibility_onboarding_continue"))
        }
        .task {
            Analytics.trackOnboardingStep(0, stepName: "value_hook")
        }
    }
}

// MARK: - Benefit Row

struct BenefitRow: View {
    let icon: String
    let color: Color
    let text: String
    let iconSize: CGFloat

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: iconSize * 0.7))
                .foregroundStyle(color)
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
    ValueHookScreen(state: OnboardingState())
}
