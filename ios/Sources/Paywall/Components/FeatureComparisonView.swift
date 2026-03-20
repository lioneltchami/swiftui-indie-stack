//
//  FeatureComparisonView.swift
//  MyApp
//
//  Free vs Premium feature comparison matrix for the custom paywall.
//  Shows checkmark/x icons for each feature to visually communicate
//  the value of upgrading to premium.
//

import SwiftUI

struct FeatureComparisonView: View {

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack {
                Text(String(localized: "paywall_features_header"))
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                Text(String(localized: "paywall_free_column"))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 48)

                Text(String(localized: "paywall_premium_column"))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.premium)
                    .frame(width: 64)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            // Feature rows
            ForEach(PaywallConfiguration.features) { feature in
                featureRow(feature)

                if feature.id != PaywallConfiguration.features.last?.id {
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.backgroundSecondary)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Feature Row

    @ViewBuilder
    private func featureRow(_ feature: PaywallConfiguration.FeatureRow) -> some View {
        HStack {
            Text(feature.name)
                .font(.subheadline)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(2)

            Spacer()

            // Free column
            featureIcon(included: feature.freeIncluded)
                .frame(width: 48)

            // Premium column
            featureIcon(included: feature.premiumIncluded)
                .frame(width: 64)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(featureAccessibilityLabel(feature))
    }

    @ViewBuilder
    private func featureIcon(included: Bool) -> some View {
        if included {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppColors.success)
                .font(.body)
        } else {
            Image(systemName: "xmark.circle")
                .foregroundColor(AppColors.textTertiary)
                .font(.body)
        }
    }

    // MARK: - Accessibility

    private func featureAccessibilityLabel(_ feature: PaywallConfiguration.FeatureRow) -> String {
        let freeStatus = feature.freeIncluded
            ? String(localized: "paywall_feature_included")
            : String(localized: "paywall_feature_not_included")
        let premiumStatus = feature.premiumIncluded
            ? String(localized: "paywall_feature_included")
            : String(localized: "paywall_feature_not_included")
        return "\(feature.name). \(String(localized: "paywall_free_column")): \(freeStatus). \(String(localized: "paywall_premium_column")): \(premiumStatus)"
    }
}

// MARK: - Preview

#Preview {
    FeatureComparisonView()
        .padding()
}
