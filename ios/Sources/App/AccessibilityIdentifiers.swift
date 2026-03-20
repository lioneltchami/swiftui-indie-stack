enum AccessibilityID {
    enum Onboarding {
        static let nextButton = "onboarding_next_button"
        static let skipButton = "onboarding_skip_button"
        static let getStartedButton = "onboarding_get_started_button"
        static let pageIndicator = "onboarding_page_indicator"
        static func page(_ index: Int) -> String { "onboarding_page_\(index)" }
    }

    enum Home {
        static let completeGoalButton = "home_complete_goal_button"
        static let streakBadge = "home_streak_badge"
        static let featureStatusSection = "home_feature_status"
        static let showPaywallButton = "home_show_paywall_button"
    }

    enum Library {
        static let searchButton = "library_search_button"
        static let refreshButton = "library_refresh_button"
        static let searchField = "library_search_field"
        static let categoryFilter = "library_category_filter"
        static func entryRow(_ id: String) -> String { "library_entry_\(id)" }
    }

    enum Settings {
        static let signInLink = "settings_sign_in"
        static let signOutButton = "settings_sign_out"
        static let themePicker = "settings_theme_picker"
        static let manageSubscription = "settings_manage_subscription"
        static let restorePurchases = "settings_restore_purchases"
    }

    enum TabBar {
        static let homeTab = "tab_home"
        static let libraryTab = "tab_library"
        static let settingsTab = "tab_settings"
    }

    enum Paywall {
        static let closeButton = "paywall_close_button"
        static let subscribeButton = "paywall_subscribe_button"
        static let restoreButton = "paywall_restore_button"
        static func planCard(_ plan: String) -> String { "paywall_plan_\(plan)" }
    }

    enum NotificationPriming {
        static let enableButton = "notification_enable_button"
        static let skipButton = "notification_skip_button"
    }

    enum Personalization {
        static func goalOption(_ index: Int) -> String { "personalization_goal_\(index)" }
        static func frequencyOption(_ index: Int) -> String { "personalization_freq_\(index)" }
    }

    enum Streak {
        static let badgeView = "streak_badge"
        static let compactBadge = "streak_compact_badge"
        static let atRiskBanner = "streak_at_risk_banner"
        static let calendarView = "streak_calendar"
        static func calendarDay(_ day: Int) -> String { "streak_calendar_day_\(day)" }
        static let freezeView = "streak_freeze_view"
        static let freezeIndicator = "streak_freeze_indicator"
        static let repairView = "streak_repair_view"
        static let milestoneShareView = "streak_milestone_share"
        static let useFreezeButton = "streak_use_freeze_button"
        static let getMoreFreezesButton = "streak_get_more_freezes_button"
        static let repairButton = "streak_repair_button"
        static let shareButton = "streak_milestone_share_button"
    }
}
