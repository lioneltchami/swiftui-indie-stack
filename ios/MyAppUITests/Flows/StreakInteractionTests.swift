//
//  StreakInteractionTests.swift
//  MyAppUITests
//
//  UI tests for streak-related interactions including goal completion
//  and streak badge visibility.
//

import XCTest

final class StreakInteractionTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Goal Completion Tests

    /// Test that tapping the complete goal button triggers the interaction.
    func testTapCompleteGoalButton() throws {
        app.launchForTesting()
        let home = HomePage(app: app)

        // Verify the complete goal button exists on the home screen
        home.assertCompleteGoalButtonExists()

        // Tap the button to complete the goal
        home.tapCompleteGoal()

        // After tapping, the button should update its label
        // (it changes to "Goal Completed Today!" and becomes disabled)
        let completedButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "Completed")
        )
        XCTAssertTrue(completedButton.firstMatch.waitForExistence(timeout: 2),
                      "Expected button to show completed state after tapping")
    }

    // MARK: - Streak Badge Tests

    /// Test that the streak badge is visible in the navigation bar when streaks are enabled.
    func testStreakBadgeVisibleWhenEnabled() throws {
        app.launchForTesting()
        let home = HomePage(app: app)

        // The streak badge should be visible in the toolbar
        // when AppConfiguration.enableStreaks is true
        home.assertStreakBadgeExists()
    }
}
