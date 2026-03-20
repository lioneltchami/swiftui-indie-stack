//
//  NotificationPrimingScreen.swift
//  MyApp
//
//  Onboarding Screen 4: Pre-permission notification priming.
//  Explains the benefits of notifications before showing the system permission prompt.
//  This pattern increases notification opt-in rates by setting user expectations.
//

import SwiftUI

struct NotificationPrimingScreen: View {
    let state: OnboardingState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var bellSize: CGFloat = 80
    @ScaledMetric(relativeTo: .body) private var benefitIconSize: CGFloat = 24

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Notification illustration
            Image(systemName: "bell.badge.fill")
                .font(.system(size: bellSize))
                .foregroundStyle(.purple)
                .symbolEffect(.bounce, options: reduceMotion ? .nonRepeating : .repeating)
                .accessibilityHidden(true)

            VStack(spacing: 16) {
                Text(String(localized: "notification_priming_title"))
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(String(localized: "notification_priming_body"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Benefits of notifications
            VStack(alignment: .leading, spacing: 12) {
                NotificationBenefit(
                    icon: "flame.fill",
                    text: String(localized: "notification_benefit_streak"),
                    iconSize: benefitIconSize
                )
                NotificationBenefit(
                    icon: "trophy.fill",
                    text: String(localized: "notification_benefit_milestone"),
                    iconSize: benefitIconSize
                )
                NotificationBenefit(
                    icon: "sparkles",
                    text: String(localized: "notification_benefit_content"),
                    iconSize: benefitIconSize
                )
            }
            .padding(.horizontal, 40)

            Spacer()

            VStack(spacing: 16) {
                Button(String(localized: "notification_enable_button")) {
                    Task {
                        await requestNotificationPermission()
                        advanceToNextStep()
                    }
                }
                .primaryStyle()
                .padding(.horizontal, 40)
                .accessibilityLabel(String(localized: "accessibility_notification_enable"))
                .accessibilityIdentifier(AccessibilityID.NotificationPriming.enableButton)

                Button(String(localized: "notification_skip_button")) {
                    advanceToNextStep()
                }
                .tertiaryStyle()
                .accessibilityLabel(String(localized: "accessibility_notification_skip"))
                .accessibilityIdentifier(AccessibilityID.NotificationPriming.skipButton)
            }
            .padding(.bottom, 40)
        }
        .task {
            Analytics.trackOnboardingStep(3, stepName: "notification_priming")
        }
    }

    private func advanceToNextStep() {
        if reduceMotion {
            state.currentStep = 4
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                state.currentStep = 4
            }
        }
    }

    private func requestNotificationPermission() async {
        let granted = await NotificationManager.shared.requestAuthorization()
        state.notificationsAccepted = granted
        Analytics.track(event: AnalyticsEvents.notificationPermission, parameters: ["granted": String(granted)])
    }
}

// MARK: - Notification Benefit Row

struct NotificationBenefit: View {
    let icon: String
    let text: String
    let iconSize: CGFloat

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: iconSize * 0.7))
                .foregroundStyle(.purple)
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
    NotificationPrimingScreen(state: OnboardingState())
}
