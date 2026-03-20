//
//  StreakFreezeIndicator.swift
//  MyApp
//
//  Small snowflake badge overlay showing the number of freezes available.
//  Designed to be placed next to or overlaid on the streak badge.
//

import SwiftUI

struct StreakFreezeIndicator: View {
    let freezeCount: Int
    let isActive: Bool

    @ScaledMetric(relativeTo: .caption) private var iconSize: CGFloat = 14

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: isActive ? "snowflake.circle.fill" : "snowflake")
                .font(.system(size: iconSize))
                .foregroundColor(isActive ? .white : .cyan)
                .accessibilityHidden(true)

            Text("\(freezeCount)")
                .font(.caption2.weight(.bold))
                .foregroundColor(isActive ? .white : .cyan)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(isActive ? Color.cyan : Color.cyan.opacity(0.15))
        )
        .accessibilityIdentifier(AccessibilityID.Streak.freezeIndicator)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(freezeAccessibilityLabel)
    }

    private var freezeAccessibilityLabel: String {
        if isActive {
            return String(localized: "accessibility_freeze_active")
        } else {
            return String(localized: "accessibility_freeze_available \(freezeCount)")
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        StreakFreezeIndicator(freezeCount: 2, isActive: false)
        StreakFreezeIndicator(freezeCount: 1, isActive: true)
        StreakFreezeIndicator(freezeCount: 0, isActive: false)
    }
    .padding()
}
