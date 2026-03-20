//
//  PersonalizationScreen2.swift
//  MyApp
//
//  Onboarding Screen 3: Frequency selector.
//  Lets the user choose how often they want to engage: daily, weekdays, or 3x per week.
//  Uses tappable cards matching the design language from PersonalizationScreen1.
//

import SwiftUI

struct PersonalizationScreen2: View {
    let state: OnboardingState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .title3) private var cardIconSize: CGFloat = 32

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text(String(localized: "personalization_frequency_title"))
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(String(localized: "personalization_frequency_subtitle"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Frequency cards
            VStack(spacing: 12) {
                ForEach(Array(OnboardingState.GoalFrequency.allCases.enumerated()), id: \.element) { index, frequency in
                    FrequencyCardView(
                        frequency: frequency,
                        isSelected: state.selectedFrequency == frequency,
                        iconSize: cardIconSize
                    ) {
                        state.selectedFrequency = frequency
                    }
                    .accessibilityIdentifier(AccessibilityID.Personalization.frequencyOption(index))
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(String(localized: "onboarding_continue")) {
                if reduceMotion {
                    state.currentStep = 3
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        state.currentStep = 3
                    }
                }
            }
            .primaryStyle()
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
            .accessibilityLabel(String(localized: "accessibility_onboarding_continue"))
        }
        .task {
            Analytics.trackOnboardingStep(2, stepName: "personalization_frequency")
        }
    }
}

// MARK: - Frequency Card View

struct FrequencyCardView: View {
    let frequency: OnboardingState.GoalFrequency
    let isSelected: Bool
    let iconSize: CGFloat
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: frequency.icon)
                    .font(.system(size: iconSize * 0.7))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: iconSize, height: iconSize)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(frequency.localizedTitle)
                        .font(AppFonts.headline)
                        .foregroundStyle(.primary)

                    Text(frequency.description)
                        .font(AppFonts.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColors.primary)
                        .font(.title3)
                        .accessibilityHidden(true)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AppColors.primary.opacity(0.1) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(frequency.localizedTitle)
        .accessibilityHint(frequency.description)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    PersonalizationScreen2(state: OnboardingState())
}
