//
//  PricingTierCard.swift
//  MyApp
//
//  Individual pricing tier card for the custom paywall.
//  Supports selected state, recommended badge ("BEST VALUE"),
//  monthly equivalent display, and savings badge.
//

import SwiftUI

struct PricingTierCard: View {
    let plan: PaywallConfiguration.Plan
    let isSelected: Bool
    let isRecommended: Bool
    let onSelect: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                // "BEST VALUE" badge for recommended plan
                if isRecommended {
                    Text(String(localized: "paywall_best_value"))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(AppColors.primary)
                }

                VStack(spacing: 8) {
                    // Plan name
                    Text(plan.displayName)
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    // Price
                    Text(plan.price)
                        .font(isRecommended ? .title2 : .title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    // Monthly equivalent for yearly plan
                    if let monthlyEquivalent = plan.monthlyEquivalent {
                        Text(String(localized: "paywall_monthly_equivalent \(monthlyEquivalent)"))
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    // Savings badge
                    if let savings = plan.savingsText {
                        Text(savings)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(AppColors.accent)
                            )
                    }
                }
                .padding(.vertical, isRecommended ? 20 : 16)
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AppColors.primary.opacity(0.08) : AppColors.backgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? AppColors.primary : Color.clear,
                        lineWidth: isSelected ? 2.5 : 0
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .if(isSelected) { view in
                view.liquidGlass(cornerRadius: 16)
            }
            .shadow(
                color: isRecommended ? AppColors.primary.opacity(0.15) : Color.clear,
                radius: isRecommended ? 8 : 0,
                y: isRecommended ? 4 : 0
            )
            .scaleEffect(reduceMotion ? 1.0 : (isSelected ? 1.02 : 1.0))
            .animation(
                reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7),
                value: isSelected
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityHint(
            isSelected
                ? String(localized: "paywall_plan_selected_hint")
                : String(localized: "paywall_plan_tap_hint")
        )
    }

    // MARK: - Accessibility

    private var accessibilityDescription: String {
        var description = "\(plan.displayName), \(plan.price)"
        if let savings = plan.savingsText {
            description += ", \(savings)"
        }
        if isRecommended {
            description += ", \(String(localized: "paywall_best_value"))"
        }
        return description
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        PricingTierCard(
            plan: .monthly,
            isSelected: false,
            isRecommended: false,
            onSelect: {}
        )

        PricingTierCard(
            plan: .yearly,
            isSelected: true,
            isRecommended: true,
            onSelect: {}
        )

        PricingTierCard(
            plan: .lifetime,
            isSelected: false,
            isRecommended: false,
            onSelect: {}
        )
    }
    .padding()
}
