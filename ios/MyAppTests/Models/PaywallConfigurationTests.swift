import Testing
@testable import MyApp

@Suite("PaywallConfiguration Tests")
struct PaywallConfigurationTests {

    // MARK: - Plan Prices

    @Test("Plan enum has correct prices")
    func planPrices() {
        #expect(PaywallConfiguration.Plan.monthly.price == "$9.99/mo")
        #expect(PaywallConfiguration.Plan.yearly.price == "$59.99/yr")
        #expect(PaywallConfiguration.Plan.lifetime.price == "$199.99")
    }

    @Test("Plan enum has all three cases")
    func planCaseCount() {
        #expect(PaywallConfiguration.Plan.allCases.count == 3)
    }

    // MARK: - Savings Text

    @Test("Yearly plan has savings text")
    func yearlySavingsText() {
        let savings = PaywallConfiguration.Plan.yearly.savingsText
        #expect(savings != nil)
    }

    @Test("Monthly plan has nil savings text")
    func monthlySavingsTextIsNil() {
        #expect(PaywallConfiguration.Plan.monthly.savingsText == nil)
    }

    @Test("Lifetime plan has nil savings text")
    func lifetimeSavingsTextIsNil() {
        #expect(PaywallConfiguration.Plan.lifetime.savingsText == nil)
    }

    // MARK: - Monthly Equivalent

    @Test("Yearly plan has monthly equivalent of $4.99/mo")
    func yearlyMonthlyEquivalent() {
        #expect(PaywallConfiguration.Plan.yearly.monthlyEquivalent == "$4.99/mo")
    }

    @Test("Monthly plan has nil monthly equivalent")
    func monthlyHasNoEquivalent() {
        #expect(PaywallConfiguration.Plan.monthly.monthlyEquivalent == nil)
    }

    @Test("Lifetime plan has nil monthly equivalent")
    func lifetimeHasNoEquivalent() {
        #expect(PaywallConfiguration.Plan.lifetime.monthlyEquivalent == nil)
    }

    // MARK: - Default Config

    @Test("defaultConfig has default variant")
    func defaultConfigVariant() {
        let config = PaywallConfiguration.defaultConfig
        #expect(config.variant == .default)
    }

    @Test("defaultConfig has no urgency text")
    func defaultConfigNoUrgency() {
        let config = PaywallConfiguration.defaultConfig
        #expect(config.urgencyText == nil)
    }

    @Test("defaultConfig has social proof count")
    func defaultConfigSocialProof() {
        let config = PaywallConfiguration.defaultConfig
        #expect(config.socialProofCount == "50,000+")
    }

    // MARK: - Variant Configs

    @Test("All variant configs exist and have correct variants")
    func allVariantConfigsExist() {
        let defaultCfg = PaywallConfiguration.defaultConfig
        #expect(defaultCfg.variant == .default)

        let urgencyCfg = PaywallConfiguration.urgencyConfig
        #expect(urgencyCfg.variant == .urgency)

        let socialCfg = PaywallConfiguration.socialProofConfig
        #expect(socialCfg.variant == .socialProof)

        let minimalCfg = PaywallConfiguration.minimalConfig
        #expect(minimalCfg.variant == .minimal)
    }

    @Test("Urgency config has urgency text")
    func urgencyConfigHasUrgencyText() {
        let config = PaywallConfiguration.urgencyConfig
        #expect(config.urgencyText != nil)
    }

    @Test("Social proof and minimal configs have no urgency text")
    func nonUrgencyConfigsLackUrgencyText() {
        #expect(PaywallConfiguration.socialProofConfig.urgencyText == nil)
        #expect(PaywallConfiguration.minimalConfig.urgencyText == nil)
    }

    // MARK: - Config Lookup

    @Test("config(for:) returns correct variant for known strings")
    func configForVariantString() {
        let defaultCfg = PaywallConfiguration.config(for: "default")
        #expect(defaultCfg.variant == .default)

        let urgencyCfg = PaywallConfiguration.config(for: "urgency")
        #expect(urgencyCfg.variant == .urgency)

        let socialCfg = PaywallConfiguration.config(for: "social")
        #expect(socialCfg.variant == .socialProof)

        let minimalCfg = PaywallConfiguration.config(for: "minimal")
        #expect(minimalCfg.variant == .minimal)
    }

    @Test("config(for:) returns default for unknown variant string")
    func configForUnknownVariantReturnsDefault() {
        let config = PaywallConfiguration.config(for: "nonexistent")
        #expect(config.variant == .default)
    }

    // MARK: - Feature Comparison

    @Test("Features list is non-empty")
    func featuresListIsNonEmpty() {
        #expect(!PaywallConfiguration.features.isEmpty)
    }

    @Test("All features have premium included")
    func allFeaturesHavePremium() {
        for feature in PaywallConfiguration.features {
            #expect(feature.premiumIncluded == true, "Feature '\(feature.name)' should be included in premium")
        }
    }

    @Test("Some features are free, some are premium-only")
    func mixOfFreeAndPremiumFeatures() {
        let freeFeatures = PaywallConfiguration.features.filter { $0.freeIncluded }
        let premiumOnlyFeatures = PaywallConfiguration.features.filter { !$0.freeIncluded }

        #expect(!freeFeatures.isEmpty, "Should have at least one free feature")
        #expect(!premiumOnlyFeatures.isEmpty, "Should have at least one premium-only feature")
    }

    // MARK: - Plan Display Properties

    @Test("All plans have non-empty display names")
    func planDisplayNames() {
        for plan in PaywallConfiguration.Plan.allCases {
            #expect(!plan.displayName.isEmpty)
        }
    }

    @Test("All plans have non-empty CTA text")
    func planCtaText() {
        for plan in PaywallConfiguration.Plan.allCases {
            #expect(!plan.ctaText.isEmpty)
        }
    }
}
