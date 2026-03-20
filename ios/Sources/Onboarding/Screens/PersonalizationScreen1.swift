//
//  PersonalizationScreen1.swift
//  MyApp
//
//  Onboarding Screen 2: "What's your goal?" selector.
//  Presents 3-4 tappable card options to capture the user's primary goal,
//  building investment in the onboarding flow.
//

import SwiftUI

struct PersonalizationScreen1: View {
    let state: OnboardingState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .title3) private var cardIconSize: CGFloat = 32

    private let goals: [GoalOption] = [
        GoalOption(
            id: "build_habit",
            titleKey: "goal_build_habit",
            descriptionKey: "goal_build_habit_desc",
            icon: "repeat.circle.fill",
            color: .green
        ),
        GoalOption(
            id: "stay_consistent",
            titleKey: "goal_stay_consistent",
            descriptionKey: "goal_stay_consistent_desc",
            icon: "checkmark.seal.fill",
            color: .blue
        ),
        GoalOption(
            id: "track_progress",
            titleKey: "goal_track_progress",
            descriptionKey: "goal_track_progress_desc",
            icon: "chart.bar.fill",
            color: .orange
        ),
        GoalOption(
            id: "challenge_myself",
            titleKey: "goal_challenge_myself",
            descriptionKey: "goal_challenge_myself_desc",
            icon: "flame.fill",
            color: .red
        )
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text(String(localized: "personalization_goal_title"))
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(String(localized: "personalization_goal_subtitle"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Goal cards
            VStack(spacing: 12) {
                ForEach(Array(goals.enumerated()), id: \.element.id) { index, goal in
                    GoalCardView(
                        goal: goal,
                        isSelected: state.selectedGoal == goal.id,
                        iconSize: cardIconSize
                    ) {
                        state.selectedGoal = goal.id
                    }
                    .accessibilityIdentifier(AccessibilityID.Personalization.goalOption(index))
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(String(localized: "onboarding_continue")) {
                if reduceMotion {
                    state.currentStep = 2
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        state.currentStep = 2
                    }
                }
            }
            .primaryStyle(isEnabled: state.selectedGoal != nil)
            .disabled(state.selectedGoal == nil)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
            .accessibilityLabel(String(localized: "accessibility_onboarding_continue"))
        }
        .task {
            Analytics.trackOnboardingStep(1, stepName: "personalization_goal")
        }
    }
}

// MARK: - Goal Option Model

struct GoalOption: Identifiable {
    let id: String
    let titleKey: String
    let descriptionKey: String
    let icon: String
    let color: Color

    var localizedTitle: String {
        String(localized: String.LocalizationValue(titleKey))
    }

    var localizedDescription: String {
        String(localized: String.LocalizationValue(descriptionKey))
    }
}

// MARK: - Goal Card View

struct GoalCardView: View {
    let goal: GoalOption
    let isSelected: Bool
    let iconSize: CGFloat
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: goal.icon)
                    .font(.system(size: iconSize * 0.7))
                    .foregroundStyle(goal.color)
                    .frame(width: iconSize, height: iconSize)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.localizedTitle)
                        .font(AppFonts.headline)
                        .foregroundStyle(.primary)

                    Text(goal.localizedDescription)
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
        .accessibilityLabel(goal.localizedTitle)
        .accessibilityHint(goal.localizedDescription)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    PersonalizationScreen1(state: OnboardingState())
}
