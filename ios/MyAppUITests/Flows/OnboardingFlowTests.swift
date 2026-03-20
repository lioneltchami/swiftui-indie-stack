//
//  OnboardingFlowTests.swift
//  MyAppUITests
//
//  End-to-end UI tests for the onboarding flow.
//  Tests navigation through onboarding pages via next, skip, and get started buttons.
//

import XCTest

final class OnboardingFlowTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Flow Tests

    /// Test advancing through all 3 onboarding pages using the next button,
    /// then tapping get started on the last page.
    func testAdvanceThroughAllPages() throws {
        app.launchForOnboardingTest()
        let onboarding = OnboardingPage(app: app)

        // Page 1: tap next
        onboarding
            .assertOnPage(0)
            .tapNext()

        // Page 2: tap next
        onboarding
            .assertOnPage(1)
            .tapNext()

        // Page 3: tap get started
        onboarding
            .assertOnPage(2)
            .assertGetStartedButtonExists()
            .tapGetStarted()

        // Verify we landed on the main screen (home tab should be visible)
        let homeTab = app.buttons["tab_home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 3),
                      "Expected to reach the main screen after completing onboarding")
    }

    /// Test that tapping skip on the first page goes directly to the main screen.
    func testSkipButtonGoesToMainScreen() throws {
        app.launchForOnboardingTest()
        let onboarding = OnboardingPage(app: app)

        onboarding
            .assertSkipButtonExists()
            .tapSkip()

        // Verify we landed on the main screen
        let homeTab = app.buttons["tab_home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 3),
                      "Expected to reach the main screen after tapping skip")
    }

    /// Test that tapping get started on the last page goes to the main screen.
    func testGetStartedOnLastPageGoesToMainScreen() throws {
        app.launchForOnboardingTest()
        let onboarding = OnboardingPage(app: app)

        // Navigate to the last page
        onboarding
            .tapNext()
            .tapNext()

        // Tap get started
        onboarding.tapGetStarted()

        // Verify we landed on the main screen
        let homeTab = app.buttons["tab_home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 3),
                      "Expected to reach the main screen after get started")
    }
}
