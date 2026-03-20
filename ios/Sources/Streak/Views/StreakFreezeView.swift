//
//  StreakFreezeView.swift
//  MyApp
//
//  Displays streak freeze status with options to use or purchase freezes.
//  Free users get 1 freeze per month; premium users get unlimited.
//

import SwiftUI

struct StreakFreezeView: View {
    let streakData: StreakData
    let isPremium: Bool
    let onUseFreeze: () -> Void
    let onBuyFreeze: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Freeze status header
            HStack {
                Image(systemName: "snowflake")
                    .font(.title2)
                    .foregroundColor(.cyan)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "streak_freeze_title"))
                        .font(.headline)

                    Text(String(localized: "streak_freeze_available \(streakData.freezesAvailable)"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .accessibilityElement(children: .combine)

            // Use freeze button (only when streak is at risk and freezes are available)
            if streakData.isAtRisk && streakData.freezesAvailable > 0 {
                Button {
                    onUseFreeze()
                } label: {
                    Label(String(localized: "streak_use_freeze"), systemImage: "snowflake")
                        .frame(maxWidth: .infinity)
                }
                .primaryStyle()
                .accessibilityIdentifier(AccessibilityID.Streak.useFreezeButton)
                .accessibilityHint(String(localized: "accessibility_freeze_use_hint"))
            }

            // Buy more freezes (for free users -- premium upsell)
            if !isPremium {
                Button {
                    onBuyFreeze()
                } label: {
                    Label(String(localized: "streak_get_more_freezes"), systemImage: "crown.fill")
                        .frame(maxWidth: .infinity)
                }
                .secondaryStyle()
                .accessibilityIdentifier(AccessibilityID.Streak.getMoreFreezesButton)
                .accessibilityHint(String(localized: "accessibility_freeze_buy_hint"))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .liquidGlass(cornerRadius: 16)
        .accessibilityIdentifier(AccessibilityID.Streak.freezeView)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        StreakFreezeView(
            streakData: StreakData(
                currentStreak: 5,
                bestStreak: 10,
                lastActivityDate: nil,
                streakStartDate: nil,
                isAtRisk: true,
                freezesAvailable: 2,
                freezeActive: false,
                activeDays: []
            ),
            isPremium: false,
            onUseFreeze: {},
            onBuyFreeze: {}
        )

        StreakFreezeView(
            streakData: StreakData(
                currentStreak: 5,
                bestStreak: 10,
                lastActivityDate: nil,
                streakStartDate: nil,
                isAtRisk: false,
                freezesAvailable: 1,
                freezeActive: false,
                activeDays: []
            ),
            isPremium: true,
            onUseFreeze: {},
            onBuyFreeze: {}
        )
    }
    .padding()
}
