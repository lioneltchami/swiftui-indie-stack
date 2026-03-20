//
//  HomePage.swift
//  MyAppUITests
//
//  Page Object Model for the HomeView.
//  Encapsulates element queries and user interaction methods.
//

import XCTest

struct HomePage {
    let app: XCUIApplication

    // MARK: - Elements

    var completeGoalButton: XCUIElement {
        app.buttons["home_complete_goal_button"]
    }

    var streakBadge: XCUIElement {
        app.otherElements["home_streak_badge"]
    }

    var featureStatusSection: XCUIElement {
        app.otherElements["home_feature_status"]
    }

    var showPaywallButton: XCUIElement {
        app.buttons["home_show_paywall_button"]
    }

    // MARK: - Actions

    @discardableResult
    func tapCompleteGoal() -> Self {
        completeGoalButton.tap()
        return self
    }

    @discardableResult
    func tapShowPaywall() -> Self {
        showPaywallButton.tap()
        return self
    }

    // MARK: - Assertions

    @discardableResult
    func assertCompleteGoalButtonExists() -> Self {
        XCTAssertTrue(completeGoalButton.waitForExistence(timeout: 2),
                      "Expected complete goal button to exist")
        return self
    }

    @discardableResult
    func assertStreakBadgeExists() -> Self {
        XCTAssertTrue(streakBadge.waitForExistence(timeout: 2),
                      "Expected streak badge to exist")
        return self
    }

    @discardableResult
    func assertFeatureStatusVisible() -> Self {
        XCTAssertTrue(featureStatusSection.waitForExistence(timeout: 2),
                      "Expected feature status section to exist")
        return self
    }
}
