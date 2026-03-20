# Customization Checklist

Follow this checklist when cloning the SwiftUI Indie Stack template for your own app.

## 1. Project Identity

- [ ] Rename Xcode project from `MyApp` to your app name
- [ ] Update Bundle Identifier (e.g., `com.yourcompany.yourapp`)
- [ ] Update `AppConfiguration.appName` from `"Your App Name"`
- [ ] Update `AppConfiguration.appStoreID` from `"YOUR_APP_STORE_ID"`
- [ ] Update `AppConfiguration.supportEmail` from `"support@yourapp.com"`
- [ ] Replace `Image("Mascot")` in HomeView with your app icon/mascot
- [ ] Update app icon in Assets.xcassets

## 2. API Keys & Services

- [ ] Set `AppConfiguration.revenueCatAPIKey` (get from https://app.revenuecat.com)
- [ ] Set `AppConfiguration.telemetryDeckAppID` (get from https://dashboard.telemetrydeck.com)
- [ ] If using Firebase: add `GoogleService-Info.plist` and set `useFirebase = true`
- [ ] Update `AppConfiguration.libraryIndexURL` to your content repository
- [ ] Update `AppConfiguration.termsOfServiceURL` to your Terms of Service
- [ ] Update `AppConfiguration.privacyPolicyURL` to your Privacy Policy

## 3. App Group & Widget

- [ ] Create App Group in Apple Developer Portal (format: `group.com.yourcompany.yourapp.widgets`)
- [ ] Update App Group identifier in Xcode Signing & Capabilities for BOTH targets
- [ ] Update `StorageKeys.appGroupSuite` (or hardcoded strings in `WidgetHelper.swift` and `WidgetDataModels.swift`)
- [ ] Update widget display names in `StreakWidget.swift` and `LockScreenStreakWidget.swift`

## 4. Feature Flags

Review `AppConfiguration.swift` and set your desired configuration:

- [ ] `useFirebase` -- Enable/disable Firebase backend
- [ ] `useRevenueCat` -- Enable/disable subscriptions
- [ ] `useTelemetryDeck` -- Enable/disable analytics
- [ ] `enableAuth` -- Enable/disable sign-in UI
- [ ] `enableStreaks` -- Enable/disable streak tracking
- [ ] `enableLibrary` -- Enable/disable CMS library
- [ ] `enableWidgets` -- Enable/disable home screen widgets
- [ ] `enableAppReview` -- Enable/disable review prompts

## 5. Content

- [ ] Replace articles in `content/` directory with your own
- [ ] Update `content/index.json` with your article metadata
- [ ] Host content on your own GitHub repository or CDN
- [ ] Update category names and colors in `LibraryModel.swift` extensions

## 6. UI Customization

- [ ] Update colors in `UI/Theme/AppColors.swift`
- [ ] Update fonts in `UI/Theme/AppFonts.swift`
- [ ] Customize onboarding screens in `OnboardingView.swift`
- [ ] Replace placeholder text in `HomeView` ("Welcome to MyApp")
- [ ] Remove template credit link in `SettingsView` (or keep it!)

## 7. CI/CD Setup

- [ ] Set up GitHub Secrets for TestFlight deployment (see `deploy-testflight.yml`)
- [ ] Create certificates repository for Fastlane Match
- [ ] Set up Codecov account and add `CODECOV_TOKEN` secret
- [ ] Test CI pipeline by pushing to a branch

## 8. App Store Preparation

- [ ] Create App Store Connect listing
- [ ] Prepare 5.5" and 6.5" screenshots
- [ ] Write app description (first 3 lines are most visible)
- [ ] Set up keywords (100 characters max)
- [ ] Configure subscription products in App Store Connect
- [ ] Configure subscription products in RevenueCat dashboard
- [ ] Submit PrivacyInfo.xcprivacy with your actual API usage

## 9. Onboarding Flow

The onboarding uses a 5-screen flow. Customize each screen to match your app's value proposition:

- [ ] **Screen 1 (Welcome)**: Update headline, subheadline, and hero image in `WelcomeScreen.swift`
- [ ] **Screen 2 (Goal selection)**: Update goal options in `PersonalizationScreen1.swift` (id, title key, description key, icon, color)
- [ ] **Screen 3 (Frequency selection)**: Update frequency options in `OnboardingState.GoalFrequency` enum
- [ ] **Screen 4 (Notification priming)**: Update benefit descriptions in `NotificationPrimingScreen.swift` localization keys
- [ ] **Screen 5 (Paywall / Get started)**: Configure whether to show a paywall or a final CTA screen
- [ ] Add/remove onboarding screens by adjusting `OnboardingState.totalSteps` and the step switch in `OnboardingContainerView`

## 10. Custom Paywall

Configure paywall variants and pricing tiers via `PaywallConfiguration`:

- [ ] Set `PaywallConfiguration.defaultConfig` headline, subheadline, and urgency text
- [ ] Configure pricing tiers (monthly, yearly, lifetime) with display prices
- [ ] Set up A/B test variants by creating additional `PaywallConfiguration` instances
- [ ] Customize `FeatureComparisonView` to list your app's free vs. premium features
- [ ] Update `SocialProofSection` with your app's social proof messaging
- [ ] Connect RevenueCat product IDs to each `PaywallConfiguration.Plan`

## 11. Push Notifications

Set up `NotificationManager` for streak reminders and engagement:

- [ ] Configure notification categories in `NotificationManager.registerCategories()`
- [ ] Set default streak reminder time (e.g., 8:00 PM) in `NotificationManager.defaultReminderHour`
- [ ] Customize notification copy in the strings catalog (keys prefixed with `notification_`)
- [ ] Configure milestone notification thresholds (7, 30, 100, 365 days)
- [ ] Set up content update notifications for new library articles
- [ ] Test notifications on a physical device (simulators have limited notification support)

## 12. App Intents (Siri Shortcuts)

Customize Siri phrases and shortcut actions in `Intents/`:

- [ ] Update `CheckStreakIntent` display name and Siri phrase suggestions
- [ ] Update `LogActivityIntent` display name and Siri phrase suggestions
- [ ] Add custom App Intents for your domain-specific actions
- [ ] Test Siri phrases on a physical device
- [ ] Add Shortcuts app integration by conforming to `AppShortcutsProvider`

## 13. Live Activity

Customize the Live Activity and Dynamic Island appearance in `LiveActivity/`:

- [ ] Update `StreakLiveActivity` to match your app's branding (colors, icons)
- [ ] Customize the compact, minimal, and expanded Dynamic Island layouts
- [ ] Configure when Live Activities start/end (e.g., active streak session)
- [ ] Update the Lock Screen Live Activity layout and content
- [ ] Set `NSSupportsLiveActivities` to `true` in `Info.plist`

## 14. Streak Freeze Configuration

Configure streak freeze and repair limits:

- [ ] Set maximum free freezes per month in `StreakFreezeManager.maxFreeFreezesPerMonth`
- [ ] Set premium freeze limit in `StreakFreezeManager.maxPremiumFreezesPerMonth`
- [ ] Configure streak repair window (how many days back a user can repair) in `StreakRepairManager.maxRepairWindowDays`
- [ ] Set streak repair cost (if using in-app currency or premium gate)
- [ ] Customize freeze/repair UI messaging in the strings catalog

## 15. Keyboard Shortcuts (iPad)

Configure keyboard shortcuts for iPad users via `AppCommands`:

- [ ] Review default shortcuts in `AppCommands.swift` (Cmd+1 for Home, Cmd+2 for Library, etc.)
- [ ] Add domain-specific keyboard shortcuts for your features
- [ ] Ensure all shortcuts have unique key combinations and do not conflict with system shortcuts
- [ ] Test keyboard shortcuts with a physical keyboard connected to iPad

## 16. iPad NavigationSplitView

Customize the iPad sidebar layout:

- [ ] Configure sidebar items and ordering in `iPadSidebarView.swift`
- [ ] Set default detail view (what shows when no item is selected)
- [ ] Customize sidebar icons, labels, and section groupings
- [ ] Set preferred `NavigationSplitViewVisibility` (`.all`, `.detailOnly`, `.doubleColumn`)
- [ ] Test on iPad simulator and physical device in both portrait and landscape

## 17. Final Checks

- [ ] Run `swiftlint lint` and fix all warnings
- [ ] Run all tests and verify passing
- [ ] Test on physical device
- [ ] Test with Firebase disabled (local mode)
- [ ] Test with Firebase enabled (if applicable)
- [ ] Test widget on home screen
- [ ] Test dark mode
- [ ] Test with Dynamic Type (accessibility)
- [ ] Archive and validate in Xcode
