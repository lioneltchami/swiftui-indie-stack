//
//  MainTabView.swift
//  MyApp
//
//  Custom tab bar with styled icons and content switching.
//

import SwiftUI
import TipKit

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        if #available(iOS 18.0, *) {
            modernTabView
        } else {
            legacyTabView
        }
    }

    // MARK: - iOS 18+ Tab API (sidebar on iPad, tab bar on iPhone)

    @available(iOS 18.0, *)
    private var modernTabView: some View {
        TabView {
            Tab(String(localized: "tab_home"), systemImage: "house.fill") {
                HomeView()
            }

            Tab(String(localized: "tab_library"), systemImage: "book.fill") {
                LibraryView()
            }

            Tab(String(localized: "tab_settings"), systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .task {
            Analytics.trackScreenView("MainTabView")
            SettingsViewModel.shared.markAppUsage()
        }
        .withPaywall()
    }

    // MARK: - Legacy Tab View (iOS 17, ZStack-based)

    private var legacyTabView: some View {
        VStack(spacing: 0) {
            // Content views - keep all views alive to preserve state
            ZStack {
                HomeView()
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 0)

                LibraryView()
                    .opacity(selectedTab == 1 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 1)

                SettingsView()
                    .opacity(selectedTab == 2 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 2)
            }

            // Tab bar separator
            Divider()

            // Custom Tab bar
            HStack {
                Spacer(minLength: 0)

                TabBarIcon(
                    selectedTab: $selectedTab,
                    assignedTab: 0,
                    systemIconName: "house.fill",
                    tabName: String(localized: "tab_home"),
                    color: AppColors.tabHome
                )

                Spacer(minLength: 0)

                TabBarIcon(
                    selectedTab: $selectedTab,
                    assignedTab: 1,
                    systemIconName: "book.fill",
                    tabName: String(localized: "tab_library"),
                    color: AppColors.tabLibrary
                )

                Spacer(minLength: 0)

                TabBarIcon(
                    selectedTab: $selectedTab,
                    assignedTab: 2,
                    systemIconName: "gearshape.fill",
                    tabName: String(localized: "tab_settings"),
                    color: AppColors.tabSettings
                )

                Spacer(minLength: 0)
            }
            .background(AppColors.backgroundPrimary)
            .padding(.bottom, 5)
        }
        .task {
            Analytics.trackScreenView("MainTabView")
            SettingsViewModel.shared.markAppUsage()
        }
        .withPaywall()
    }
}

// MARK: - Placeholder Views (Replace with your implementations)

struct HomeView: View {
    var streakProvider = StreakViewModel.shared
    @State private var showGoalCompleted = false
    @State private var showMilestoneSheet = false
    @State private var isSessionActive = false
    @ScaledMetric(relativeTo: .title) private var mascotSize: CGFloat = 120

    /// Check if goal was already completed today
    private var goalCompletedToday: Bool {
        guard let lastActivity = streakProvider.streakData.lastActivityDate else {
            return false
        }
        return Calendar.current.isDateInToday(lastActivity)
    }

    /// Auth status detail text for Feature Status panel
    private var authDetailText: String {
        if !AppConfiguration.useFirebase {
            return String(localized: "home_auth_detail_local")
        } else if AppConfiguration.enableAuth {
            return String(localized: "home_auth_detail_apple_google")
        } else {
            return String(localized: "home_auth_detail_anonymous")
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // App mascot (placeholder - replace with your own)
                    Image("Mascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: mascotSize, height: mascotSize)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(radius: 4)
                        .padding(.top)
                        .accessibilityLabel(String(localized: "accessibility_mascot_image"))

                    // Welcome header
                    VStack(spacing: 8) {
                        Text(String(localized: "home_welcome_prefix"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(String(localized: "home_app_name"))
                            .font(AppFonts.title)
                        Text(String(localized: "home_subtitle"))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    // Streak at risk banner
                    if AppConfiguration.enableStreaks {
                        StreakAtRiskBanner()
                            .padding(.horizontal)

                        // Streak freeze card (when user has freezes or streak is at risk)
                        if streakProvider.streakData.freezesAvailable > 0 || streakProvider.streakData.isAtRisk {
                            StreakFreezeView(
                                streakData: streakProvider.streakData,
                                isPremium: PaywallManager.shared.isSubscribed,
                                onUseFreeze: {
                                    streakProvider.useFreeze()
                                },
                                onBuyFreeze: {
                                    PaywallManager.shared.triggerPaywall()
                                }
                            )
                            .padding(.horizontal)
                        }

                        // TipKit: Streak freeze protection tip
                        TipView(StreakFreezeTip())
                            .padding(.horizontal)

                        // Streak repair card (when a previous streak can be restored)
                        if streakProvider.streakData.streakRepairable,
                           let previousStreak = streakProvider.streakData.lastStreakBeforeBreak {
                            StreakRepairView(
                                previousStreak: previousStreak,
                                isPremium: PaywallManager.shared.isSubscribed,
                                onRepair: {
                                    streakProvider.repairStreak()
                                },
                                onUpgrade: {
                                    PaywallManager.shared.triggerPaywall()
                                }
                            )
                            .padding(.horizontal)
                        }
                    }

                    // Complete Goal button (demo for streak increment)
                    if AppConfiguration.enableStreaks {
                        Button {
                            completeGoal()
                        } label: {
                            Label(
                                goalCompletedToday ? String(localized: "home_goal_completed_today") : String(localized: "home_complete_goal"),
                                systemImage: goalCompletedToday ? "checkmark.circle.fill" : "target"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(goalCompletedToday ? .green : .orange)
                        .disabled(goalCompletedToday)
                        .padding(.horizontal)
                        .keyboardShortcut("d", modifiers: .command)
                        .accessibilityIdentifier(AccessibilityID.Home.completeGoalButton)
                        .accessibilityLabel(goalCompletedToday ? String(localized: "accessibility_goal_completed_today") : String(localized: "accessibility_complete_goal"))
                    }

                    Divider()
                        .padding(.horizontal)

                    // Feature Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "home_feature_status_title"))
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityAddTraits(.isHeader)

                        FeatureStatusRow(
                            name: "Firebase",
                            enabled: AppConfiguration.useFirebase,
                            icon: "cloud.fill"
                        )
                        FeatureStatusRow(
                            name: "Auth",
                            enabled: AppConfiguration.enableAuth,
                            icon: "person.badge.key.fill",
                            detail: authDetailText
                        )
                        FeatureStatusRow(
                            name: "RevenueCat",
                            enabled: AppConfiguration.useRevenueCat,
                            icon: "creditcard.fill"
                        )
                        FeatureStatusRow(
                            name: "TelemetryDeck",
                            enabled: AppConfiguration.useTelemetryDeck,
                            icon: "chart.bar.fill"
                        )
                        FeatureStatusRow(
                            name: "Streaks",
                            enabled: AppConfiguration.enableStreaks,
                            icon: "flame.fill",
                            detail: streakProvider.hasStreak ? String(localized: "home_streak_days_detail \(streakProvider.streakData.currentStreak)") : nil
                        )
                        FeatureStatusRow(
                            name: "Library/CMS",
                            enabled: AppConfiguration.enableLibrary,
                            icon: "book.fill"
                        )
                        FeatureStatusRow(
                            name: "Widgets",
                            enabled: AppConfiguration.enableWidgets,
                            icon: "square.grid.2x2.fill"
                        )
                        FeatureStatusRow(
                            name: "App Review",
                            enabled: AppConfiguration.enableAppReview,
                            icon: "star.fill",
                            detail: String(localized: "home_app_review_detail \(AppConfiguration.appReviewStreakThreshold)")
                        )
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .accessibilityIdentifier(AccessibilityID.Home.featureStatusSection)

                    Spacer(minLength: 20)

                    // Demo: Show how to trigger paywall programmatically
                    if AppConfiguration.useRevenueCat {
                        Button {
                            PaywallManager.shared.triggerPaywall()
                        } label: {
                            Label(String(localized: "home_show_paywall_demo"), systemImage: "creditcard.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                        .accessibilityIdentifier(AccessibilityID.Home.showPaywallButton)
                        .accessibilityLabel(String(localized: "accessibility_show_paywall_demo"))
                    }

                    // Start Focus Session (Live Activity)
                    if AppConfiguration.enableStreaks {
                        Button {
                            if isSessionActive {
                                SessionActivityManager.endSession()
                                isSessionActive = false
                            } else {
                                let activityId = SessionActivityManager.startSession(
                                    goalName: String(localized: "home_focus_session_goal"),
                                    streakCount: streakProvider.streakData.currentStreak
                                )
                                isSessionActive = activityId != nil
                            }
                        } label: {
                            Label(
                                isSessionActive
                                    ? String(localized: "home_end_focus_session")
                                    : String(localized: "home_start_focus_session"),
                                systemImage: isSessionActive ? "stop.circle.fill" : "timer"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(isSessionActive ? .red : .blue)
                        .padding(.horizontal)
                        .accessibilityLabel(
                            isSessionActive
                                ? String(localized: "accessibility_end_focus_session")
                                : String(localized: "accessibility_start_focus_session")
                        )
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle(String(localized: "home_navigation_title"))
            .toolbar {
                if AppConfiguration.enableStreaks {
                    ToolbarItem(placement: .primaryAction) {
                        CompactStreakBadge()
                            .accessibilityIdentifier(AccessibilityID.Home.streakBadge)
                    }
                }
            }
        }
        .sheet(isPresented: $showMilestoneSheet) {
            StreakMilestoneShareView(
                milestone: streakProvider.streakData.currentStreak,
                appName: String(localized: "home_app_name")
            )
            .presentationDetents([.medium])
        }
        .onReceive(NotificationCenter.default.publisher(for: .completeGoal)) { _ in
            if !goalCompletedToday {
                completeGoal()
            }
        }
    }

    private func completeGoal() {
        // Record activity for streak (works in both local and Firebase mode)
        if AppConfiguration.useFirebase {
            #if canImport(Firebase)
            FirestoreManager.shared.logActivity(type: "goal_completed")
            #endif
        } else {
            streakProvider.recordLocalActivity()
        }

        showGoalCompleted = true
        Analytics.track(event: AnalyticsEvents.goalCompleted)

        // Donate to TipKit events for contextual tip display
        Task {
            await StreakFreezeTip.streakCompletionCount.donate()
            await SiriShortcutTip.manualLogCount.donate()
        }

        // Show milestone share sheet if a milestone was just reached
        if streakProvider.isMilestone {
            showMilestoneSheet = true
        }

        // End any active Live Activity session on goal completion
        if isSessionActive {
            SessionActivityManager.endSession()
            isSessionActive = false
        }
    }
}

// MARK: - Feature Status Row

struct FeatureStatusRow: View {
    let name: String
    let enabled: Bool
    let icon: String
    var detail: String? = nil

    @ScaledMetric(relativeTo: .body) private var iconWidth: CGFloat = 24
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    var body: some View {
        ViewThatFits(in: .horizontal) {
            // Preferred horizontal layout
            horizontalLayout
            // Stacked fallback for large text sizes
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(enabled ? .green : .secondary)
                        .frame(width: iconWidth)

                    Text(name)
                        .foregroundColor(.primary)
                }

                HStack {
                    if let detail = detail {
                        Text(detail)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    statusIndicator
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(featureStatusAccessibilityLabel)
    }

    private var horizontalLayout: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(enabled ? .green : .secondary)
                .frame(width: iconWidth)

            Text(name)
                .foregroundColor(.primary)

            Spacer()

            if let detail = detail {
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.trailing, 4)
            }

            statusIndicator
        }
    }

    @ViewBuilder
    private var statusIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: enabled ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundColor(enabled ? .green : .secondary)

            if differentiateWithoutColor {
                Text(enabled ? String(localized: "accessibility_status_on") : String(localized: "accessibility_status_off"))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(enabled ? .primary : .secondary)
            }
        }
    }

    private var featureStatusAccessibilityLabel: String {
        let status = enabled ? String(localized: "accessibility_enabled") : String(localized: "accessibility_disabled")
        if let detail = detail {
            return "\(name): \(status), \(detail)"
        }
        return "\(name): \(status)"
    }
}

struct SettingsView: View {
    @Environment(AuthManager.self) var authManager
    @AppStorage(StorageKeys.appearance) var appearance: Appearance = .system

    var body: some View {
        NavigationStack {
            List {
                // Account Section
                Section(String(localized: "settings_account_section")) {
                    if authManager.authState == .signedIn {
                        #if canImport(FirebaseAuth)
                        if let email = authManager.user?.email {
                            HStack {
                                Text(String(localized: "settings_email_label"))
                                Spacer()
                                Text(email)
                                    .foregroundColor(.secondary)
                            }
                        }
                        #endif

                        Button(String(localized: "settings_sign_out"), role: .destructive) {
                            authManager.signOut()
                        }
                        .accessibilityIdentifier(AccessibilityID.Settings.signOutButton)
                        .accessibilityLabel(String(localized: "accessibility_sign_out"))
                    } else if authManager.canSignIn {
                        #if canImport(GoogleSignIn)
                        NavigationLink(value: SettingsRoute.signIn) {
                            Text(String(localized: "settings_sign_in"))
                        }
                        .accessibilityIdentifier(AccessibilityID.Settings.signInLink)
                        #endif
                    }
                }

                // Appearance Section
                Section(String(localized: "settings_appearance_section")) {
                    Picker(String(localized: "settings_theme_label"), selection: $appearance) {
                        ForEach(Appearance.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.themePicker)
                    .accessibilityLabel(String(localized: "accessibility_theme_picker"))
                }

                // Subscription Section
                Section(String(localized: "settings_subscription_section")) {
                    Button(String(localized: "settings_manage_subscription")) {
                        PaywallManager.shared.triggerPaywall()
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.manageSubscription)
                    .accessibilityLabel(String(localized: "accessibility_manage_subscription"))

                    Button(String(localized: "settings_restore_purchases")) {
                        Task {
                            try? await PaywallManager.shared.restorePurchases()
                        }
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.restorePurchases)
                    .accessibilityLabel(String(localized: "accessibility_restore_purchases"))
                }

                // About Section
                Section(String(localized: "settings_about_section")) {
                    if let termsURL = URL(string: AppConfiguration.termsOfServiceURL) {
                        Link(String(localized: "settings_terms_of_service"), destination: termsURL)
                    }
                    if let privacyURL = URL(string: AppConfiguration.privacyPolicyURL) {
                        Link(String(localized: "settings_privacy_policy"), destination: privacyURL)
                    }
                }

                // Template Credit (feel free to remove when customizing)
                Section {
                    if let url = URL(string: "https://github.com/cliffordh/swiftui-indie-stack") {
                    Link(destination: url) {
                        HStack {
                            Text(String(localized: "settings_built_with"))
                                .font(.footnote)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.footnote)
                        }
                        .foregroundColor(.secondary)
                    }
                    }
                }
            }
            .navigationTitle(String(localized: "settings_navigation_title"))
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .signIn:
                    #if canImport(GoogleSignIn)
                    LoginView()
                    #else
                    Text("Sign-in is not available")
                    #endif
                }
            }
        }
        .task {
            Analytics.trackScreenView("SettingsView")
        }
    }
}

#Preview {
    MainTabView()
        .environment(AuthManager.shared)
}
