//
//  StreakRepairView.swift
//  MyApp
//
//  "Repair your streak" card that shows the previous streak and offers
//  premium users the ability to restore it. For free users, acts as
//  a premium upsell.
//

import SwiftUI

struct StreakRepairView: View {
    let previousStreak: Int
    let isPremium: Bool
    let onRepair: () -> Void
    let onUpgrade: () -> Void

    @ScaledMetric(relativeTo: .title) private var iconSize: CGFloat = 40

    var body: some View {
        VStack(spacing: 16) {
            // Header with broken streak info
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: iconSize + 16, height: iconSize + 16)

                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: iconSize))
                        .foregroundColor(.orange)
                        .accessibilityHidden(true)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "streak_repair_title"))
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)

                    Text(String(localized: "streak_repair_description \(previousStreak)"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // Action button
            if isPremium {
                Button {
                    onRepair()
                } label: {
                    Label(String(localized: "streak_repair_button"), systemImage: "arrow.uturn.backward")
                        .frame(maxWidth: .infinity)
                }
                .primaryStyle()
                .accessibilityIdentifier(AccessibilityID.Streak.repairButton)
                .accessibilityHint(String(localized: "accessibility_repair_hint \(previousStreak)"))
            } else {
                Button {
                    onUpgrade()
                } label: {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        Text(String(localized: "streak_repair_upgrade"))
                    }
                    .frame(maxWidth: .infinity)
                }
                .secondaryStyle()
                .accessibilityIdentifier(AccessibilityID.Streak.repairButton)
                .accessibilityHint(String(localized: "accessibility_repair_upgrade_hint"))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .accessibilityIdentifier(AccessibilityID.Streak.repairView)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        StreakRepairView(
            previousStreak: 42,
            isPremium: true,
            onRepair: {},
            onUpgrade: {}
        )

        StreakRepairView(
            previousStreak: 15,
            isPremium: false,
            onRepair: {},
            onUpgrade: {}
        )
    }
    .padding()
}
