//
//  OnboardingFlowView.swift
//  MyApp
//
//  Multi-screen onboarding coordinator with progress bar and TabView navigation.
//  Replaces the old 3-screen OnboardingView with a 5-screen personalized flow:
//    1. Value Hook - communicate core value in 7 seconds
//    2. Personalization 1 - "What's your goal?"
//    3. Personalization 2 - "How often?"
//    4. Notification Priming - explain benefits before system prompt
//    5. Paywall - post-onboarding paywall (highest conversion moment)
//

import SwiftUI

struct OnboardingFlowView: View {
    @Binding var isOnboardingDone: Bool
    @State private var state = OnboardingState()

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar at top
            ProgressView(value: state.progress)
                .tint(AppColors.primary)
                .padding(.horizontal)
                .padding(.top, 8)
                .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: state.progress)
                .accessibilityLabel(
                    String(localized: "accessibility_onboarding_progress \(Int(state.progress * 100))")
                )

            TabView(selection: $state.currentStep) {
                ValueHookScreen(state: state)
                    .tag(0)

                PersonalizationScreen1(state: state)
                    .tag(1)

                PersonalizationScreen2(state: state)
                    .tag(2)

                NotificationPrimingScreen(state: state)
                    .tag(3)

                OnboardingPaywallScreen(
                    state: state,
                    onComplete: { completeOnboarding() }
                )
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: state.currentStep)
        }
    }

    private func completeOnboarding() {
        // Save personalization answers
        if let selectedGoal = state.selectedGoal {
            UserDefaults.standard.set(selectedGoal, forKey: StorageKeys.selectedGoal)
        }
        UserDefaults.standard.set(
            state.selectedFrequency.rawValue,
            forKey: StorageKeys.selectedFrequency
        )

        Analytics.trackOnboardingStep(state.totalSteps, stepName: "completed")
        isOnboardingDone = true
    }
}

#Preview {
    OnboardingFlowView(isOnboardingDone: .constant(false))
}
