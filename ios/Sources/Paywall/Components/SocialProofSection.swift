//
//  SocialProofSection.swift
//  MyApp
//
//  Social proof section for the custom paywall.
//  Displays star rating, user count, and an optional testimonial quote
//  to increase trust and conversion.
//

import SwiftUI

struct SocialProofSection: View {
    let config: PaywallConfiguration

    var body: some View {
        VStack(spacing: 16) {
            // Star rating
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < 4 ? "star.fill" : "star.leadinghalf.filled")
                        .foregroundColor(.yellow)
                        .font(.body)
                }

                Text("4.8")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(localized: "paywall_rating_accessibility"))

            // User count
            HStack(spacing: 6) {
                Image(systemName: "person.3.fill")
                    .foregroundColor(AppColors.primary)
                    .font(.subheadline)

                Text(config.socialProofText)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            .accessibilityElement(children: .combine)

            // Testimonial quote
            VStack(spacing: 8) {
                Text(String(localized: "paywall_testimonial_quote"))
                    .font(.callout)
                    .italic()
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Text(String(localized: "paywall_testimonial_author"))
                    .font(.caption)
                    .foregroundColor(AppColors.textTertiary)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.backgroundSecondary)
        )
    }
}

// MARK: - Preview

#Preview {
    SocialProofSection(config: .defaultConfig)
        .padding()
}
