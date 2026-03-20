//
//  PaywallConfiguration.swift
//  MyApp
//
//  A/B test variant support for the custom paywall.
//  Provides variant definitions, plan pricing, and feature lists
//  for the decoy pricing strategy (3-tier with annual anchoring).
//

import Foundation

struct PaywallConfiguration {
    let variant: PaywallVariant
    let headline: String
    let subheadline: String
    let socialProofText: String
    let socialProofCount: String
    let urgencyText: String?

    // MARK: - Paywall Variants

    /// A/B test variants for the custom paywall.
    /// Variant assignment should come from a remote config service
    /// (Firebase Remote Config, RevenueCat Experiments, or a custom backend).
    /// The default variant is loaded from `AppConfiguration.paywallVariant`.
    enum PaywallVariant: String, Sendable {
        case `default` = "default"
        case urgency = "urgency"       // With countdown timer
        case socialProof = "social"    // Emphasize user count
        case minimal = "minimal"       // Streamlined layout

        init(from string: String) {
            self = PaywallVariant(rawValue: string) ?? .default
        }
    }

    // MARK: - Subscription Plans

    /// Subscription plans using the decoy pricing strategy.
    /// Monthly is the baseline, yearly is the target (50% savings),
    /// and lifetime is the decoy to make yearly look attractive.
    enum Plan: String, CaseIterable, Sendable {
        case monthly
        case yearly    // Target plan (decoy effect)
        case lifetime  // Decoy to make yearly attractive

        var price: String {
            switch self {
            case .monthly: return "$9.99/mo"
            case .yearly: return "$59.99/yr"
            case .lifetime: return "$199.99"
            }
        }

        var monthlyEquivalent: String? {
            switch self {
            case .yearly: return "$4.99/mo"
            default: return nil
            }
        }

        var savingsText: String? {
            switch self {
            case .yearly: return String(localized: "paywall_savings_yearly")
            default: return nil
            }
        }

        var displayName: String {
            switch self {
            case .monthly: return String(localized: "paywall_plan_monthly")
            case .yearly: return String(localized: "paywall_plan_yearly")
            case .lifetime: return String(localized: "paywall_plan_lifetime")
            }
        }

        var ctaText: String {
            switch self {
            case .monthly: return String(localized: "paywall_cta_monthly")
            case .yearly: return String(localized: "paywall_cta_yearly")
            case .lifetime: return String(localized: "paywall_cta_lifetime")
            }
        }
    }

    // MARK: - Feature Comparison

    struct FeatureRow: Identifiable {
        let id = UUID()
        let name: String
        let freeIncluded: Bool
        let premiumIncluded: Bool
    }

    static let features: [FeatureRow] = [
        FeatureRow(
            name: String(localized: "paywall_feature_basic_tracking"),
            freeIncluded: true,
            premiumIncluded: true
        ),
        FeatureRow(
            name: String(localized: "paywall_feature_daily_streaks"),
            freeIncluded: true,
            premiumIncluded: true
        ),
        FeatureRow(
            name: String(localized: "paywall_feature_unlimited_freezes"),
            freeIncluded: false,
            premiumIncluded: true
        ),
        FeatureRow(
            name: String(localized: "paywall_feature_streak_repair"),
            freeIncluded: false,
            premiumIncluded: true
        ),
        FeatureRow(
            name: String(localized: "paywall_feature_advanced_analytics"),
            freeIncluded: false,
            premiumIncluded: true
        ),
        FeatureRow(
            name: String(localized: "paywall_feature_priority_support"),
            freeIncluded: false,
            premiumIncluded: true
        ),
    ]

    // MARK: - Preset Configurations

    static let defaultConfig = PaywallConfiguration(
        variant: .default,
        headline: String(localized: "paywall_headline_default"),
        subheadline: String(localized: "paywall_subheadline_default"),
        socialProofText: String(localized: "paywall_social_proof"),
        socialProofCount: "50,000+",
        urgencyText: nil
    )

    static let urgencyConfig = PaywallConfiguration(
        variant: .urgency,
        headline: String(localized: "paywall_headline_urgency"),
        subheadline: String(localized: "paywall_subheadline_urgency"),
        socialProofText: String(localized: "paywall_social_proof"),
        socialProofCount: "50,000+",
        urgencyText: String(localized: "paywall_urgency_text")
    )

    static let socialProofConfig = PaywallConfiguration(
        variant: .socialProof,
        headline: String(localized: "paywall_headline_social"),
        subheadline: String(localized: "paywall_subheadline_social"),
        socialProofText: String(localized: "paywall_social_proof"),
        socialProofCount: "50,000+",
        urgencyText: nil
    )

    static let minimalConfig = PaywallConfiguration(
        variant: .minimal,
        headline: String(localized: "paywall_headline_minimal"),
        subheadline: String(localized: "paywall_subheadline_minimal"),
        socialProofText: String(localized: "paywall_social_proof"),
        socialProofCount: "50,000+",
        urgencyText: nil
    )

    /// Returns the configuration for the given variant string.
    static func config(for variant: String) -> PaywallConfiguration {
        switch PaywallVariant(from: variant) {
        case .default: return defaultConfig
        case .urgency: return urgencyConfig
        case .socialProof: return socialProofConfig
        case .minimal: return minimalConfig
        }
    }
}
