import Testing
@testable import MyApp

@Suite("SettingsViewModel Tests")
@MainActor
struct SettingsViewModelTests {

    // NOTE: SettingsViewModel has private init(), so we test via .shared.
    // We also test the mock to verify protocol behavior in isolation.

    // MARK: - getSettings / restoreSettings Cycle

    @Test("getSettings returns dictionary with expected keys")
    func getSettingsReturnsExpectedKeys() async {
        let vm = SettingsViewModel.shared
        let settings = vm.getSettings()

        #expect(settings["showOnboardingOnLaunch"] != nil)
        #expect(settings["appearance"] != nil)
        #expect(settings["notificationsEnabled"] != nil)
        #expect(settings["streakReminderEnabled"] != nil)
    }

    @Test("restoreSettings applies values from dictionary")
    func restoreSettingsAppliesValues() async {
        let vm = SettingsViewModel.shared

        // Save original state
        let originalSettings = vm.getSettings()

        // Apply new settings
        let newSettings: [String: Any] = [
            "showOnboardingOnLaunch": true,
            "appearance": "Dark",
            "notificationsEnabled": true,
            "streakReminderEnabled": false,
        ]
        vm.restoreSettings(newSettings: newSettings)

        #expect(vm.showOnboardingOnLaunch == true)
        #expect(vm.appearance == .dark)
        #expect(vm.notificationsEnabled == true)
        #expect(vm.streakReminderEnabled == false)

        // Restore original settings to avoid side effects
        vm.restoreSettings(newSettings: originalSettings)
    }

    @Test("restoreSettings with empty dictionary uses defaults")
    func restoreSettingsEmptyDict() async {
        let vm = SettingsViewModel.shared

        // Save original state
        let originalSettings = vm.getSettings()

        vm.restoreSettings(newSettings: [:])
        #expect(vm.showOnboardingOnLaunch == false)
        #expect(vm.appearance == .system)
        #expect(vm.notificationsEnabled == false)
        #expect(vm.streakReminderEnabled == true)

        // Restore original settings
        vm.restoreSettings(newSettings: originalSettings)
    }

    // MARK: - App Usage Tracking

    @Test("markAppUsage updates lastAppUsageDate")
    func markAppUsageUpdatesDate() async {
        let vm = SettingsViewModel.shared
        let beforeDate = vm.lastAppUsageDate

        vm.markAppUsage()

        #expect(vm.lastAppUsageDate != nil)
        // The date should be at least as recent as before
        if let before = beforeDate, let after = vm.lastAppUsageDate {
            #expect(after >= before)
        }
    }

    // MARK: - Days Since Install

    @Test("daysSinceInstall returns non-negative value")
    func daysSinceInstallNonNegative() async {
        let vm = SettingsViewModel.shared
        #expect(vm.daysSinceInstall >= 0)
    }

    @Test("appInstallDate is set after initialization")
    func appInstallDateSet() async {
        let vm = SettingsViewModel.shared
        // Private init sets appInstallDate if nil
        #expect(vm.appInstallDate != nil)
    }

    // MARK: - Mock-Based Tests

    @Test("MockSettingsService getSettings/restoreSettings roundtrip")
    func mockGetRestoreRoundtrip() async {
        let mock = MockSettingsService()
        mock.showOnboardingOnLaunch = true
        mock.appearance = .dark
        mock.notificationsEnabled = true
        mock.streakReminderEnabled = false

        let settings = mock.getSettings()
        #expect(mock.getSettingsCallCount == 1)

        // Create a fresh mock and restore into it
        let mock2 = MockSettingsService()
        mock2.restoreSettings(newSettings: settings)

        #expect(mock2.showOnboardingOnLaunch == true)
        #expect(mock2.appearance == .dark)
        #expect(mock2.notificationsEnabled == true)
        #expect(mock2.streakReminderEnabled == false)
        #expect(mock2.restoreSettingsCallCount == 1)
    }

    @Test("MockSettingsService markAppUsage sets date and increments counter")
    func mockMarkAppUsage() async {
        let mock = MockSettingsService()
        #expect(mock.lastAppUsageDate == nil)

        mock.markAppUsage()

        #expect(mock.lastAppUsageDate != nil)
        #expect(mock.markAppUsageCallCount == 1)
    }

    @Test("MockSettingsService daysSinceInstall calculation")
    func mockDaysSinceInstall() async {
        let mock = MockSettingsService()
        mock.appInstallDate = TestData.daysAgo(10)

        #expect(mock.daysSinceInstall == 10)
    }
}
