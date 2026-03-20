//
//  StreakBadgeView.swift
//  MyApp
//
//  Displays the current streak with flame animation.
//

import SwiftUI
import ConfettiSwiftUI

struct StreakBadgeView: View {
    var streakProvider = StreakViewModel.shared

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    @State private var confettiTrigger = 0
    @State private var isAnimating = false

    @ScaledMetric(relativeTo: .body) private var badgeSize: CGFloat = 60

    var size: CGFloat = 60

    var body: some View {
        ZStack {
            // Flame icon
            Image(systemName: streakProvider.hasStreak ? "flame.fill" : "flame")
                .font(.system(size: badgeSize * 0.6))
                .foregroundColor(flameColor)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    reduceMotion ? .none :
                        (streakProvider.hasStreak ?
                            Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) :
                            .default),
                    value: isAnimating
                )

            // Streak count
            if streakProvider.hasStreak {
                Text("\(streakProvider.streakData.currentStreak)")
                    .font(.system(size: badgeSize * 0.25, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .offset(y: badgeSize * 0.15)
            }

            // Confetti for milestones
            ConfettiCannon(
                trigger: $confettiTrigger,
                num: 50,
                colors: [.orange, .red, .yellow],
                rainHeight: 400,
                radius: 300
            )
        }
        .frame(width: badgeSize, height: badgeSize)
        .overlay(alignment: .topTrailing) {
            if streakProvider.streakData.freezeActive || streakProvider.streakData.freezesAvailable > 0 {
                StreakFreezeIndicator(
                    freezeCount: streakProvider.streakData.freezesAvailable,
                    isActive: streakProvider.streakData.freezeActive
                )
                .offset(x: 8, y: -8)
            }
        }
        .accessibilityIdentifier(AccessibilityID.Streak.badgeView)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(streakAccessibilityLabel)
        .accessibilityValue("\(streakProvider.streakData.currentStreak)")
        .onAppear {
            isAnimating = streakProvider.hasStreak
        }
        .onChange(of: streakProvider.streakData.currentStreak) { oldValue, newValue in
            // Trigger confetti on milestone achievements
            if streakProvider.isMilestone && newValue > oldValue && !reduceMotion {
                confettiTrigger += 1
            }
        }
    }

    private var streakAccessibilityLabel: String {
        if streakProvider.hasStreak {
            return String(localized: "accessibility_streak_active \(streakProvider.streakData.currentStreak)")
        } else {
            return String(localized: "accessibility_streak_inactive")
        }
    }

    private var flameColor: Color {
        if !streakProvider.hasStreak {
            return .gray
        }

        let streak = streakProvider.streakData.currentStreak

        if streak >= 365 {
            return .purple  // Legendary
        } else if streak >= 100 {
            return .blue    // Epic
        } else if streak >= 30 {
            return Color.orange  // Hot
        } else if streak >= 7 {
            return .orange  // Warm
        } else {
            return .red     // Starting
        }
    }
}

// MARK: - Compact Streak Badge

struct CompactStreakBadge: View {
    var streakProvider = StreakViewModel.shared

    var body: some View {
        ViewThatFits(in: .horizontal) {
            // Preferred: icon and count side by side
            HStack(spacing: 4) {
                Image(systemName: streakProvider.hasStreak ? "flame.fill" : "flame")
                    .foregroundColor(streakProvider.hasStreak ? .orange : .gray)

                Text("\(streakProvider.streakData.currentStreak)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(streakProvider.hasStreak ? .primary : .secondary)
            }

            // Fallback: stacked layout for very large text sizes
            VStack(spacing: 2) {
                Image(systemName: streakProvider.hasStreak ? "flame.fill" : "flame")
                    .foregroundColor(streakProvider.hasStreak ? .orange : .gray)

                Text("\(streakProvider.streakData.currentStreak)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(streakProvider.hasStreak ? .primary : .secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(streakProvider.hasStreak ?
                      Color.orange.opacity(0.15) :
                      Color.secondary.opacity(0.1))
        )
        .accessibilityIdentifier(AccessibilityID.Streak.compactBadge)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Streak At Risk Banner

struct StreakAtRiskBanner: View {
    var streakProvider = StreakViewModel.shared

    var body: some View {
        if streakProvider.streakData.isAtRisk && streakProvider.hasStreak {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)

                Text(String(localized: "streak_at_risk_message \(streakProvider.streakData.currentStreak)"))
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .background(Color.yellow.opacity(0.15))
            .cornerRadius(12)
            .accessibilityIdentifier(AccessibilityID.Streak.atRiskBanner)
            .accessibilityElement(children: .combine)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        StreakBadgeView()
        CompactStreakBadge()
        StreakAtRiskBanner()
    }
    .padding()
}
