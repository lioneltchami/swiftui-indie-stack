//
//  XCUIApplication+Launch.swift
//  MyAppUITests
//
//  Launch configuration helpers for UI tests.
//  Provides standardized launch arguments for different test scenarios.
//

import XCTest

extension XCUIApplication {

    /// Launch the app configured for general UI testing.
    /// Sets "UITesting" and "SkipOnboarding" launch arguments
    /// so tests start on the main tab view.
    func launchForTesting() {
        launchArguments = ["UITesting", "SkipOnboarding"]
        launchEnvironment = [
            "UITESTING": "1",
            "ANIMATIONS_DISABLED": "1"
        ]
        launch()
    }

    /// Launch the app configured for onboarding UI tests.
    /// Sets "UITesting" but does NOT set "SkipOnboarding"
    /// so the onboarding flow is shown.
    func launchForOnboardingTest() {
        launchArguments = ["UITesting"]
        launchEnvironment = [
            "UITESTING": "1",
            "ANIMATIONS_DISABLED": "1"
        ]
        launch()
    }
}
