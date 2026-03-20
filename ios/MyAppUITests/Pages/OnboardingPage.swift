//
//  OnboardingPage.swift
//  MyAppUITests
//
//  Page Object Model for the OnboardingView.
//  Encapsulates element queries and user interaction methods.
//

import XCTest

struct OnboardingPage {
    let app: XCUIApplication

    // MARK: - Elements

    var nextButton: XCUIElement {
        app.buttons["onboarding_next_button"]
    }

    var skipButton: XCUIElement {
        app.buttons["onboarding_skip_button"]
    }

    var getStartedButton: XCUIElement {
        app.buttons["onboarding_get_started_button"]
    }

    var pageIndicator: XCUIElement {
        app.otherElements["onboarding_page_indicator"]
    }

    func page(_ index: Int) -> XCUIElement {
        app.otherElements["onboarding_page_\(index)"]
    }

    // MARK: - Actions

    @discardableResult
    func tapNext() -> Self {
        nextButton.tap()
        return self
    }

    @discardableResult
    func tapSkip() -> Self {
        skipButton.tap()
        return self
    }

    @discardableResult
    func tapGetStarted() -> Self {
        getStartedButton.tap()
        return self
    }

    // MARK: - Assertions

    @discardableResult
    func assertOnPage(_ index: Int) -> Self {
        let pageElement = page(index)
        XCTAssertTrue(pageElement.waitForExistence(timeout: 2),
                      "Expected to be on onboarding page \(index)")
        return self
    }

    @discardableResult
    func assertNextButtonExists() -> Self {
        XCTAssertTrue(nextButton.waitForExistence(timeout: 2),
                      "Expected next button to exist")
        return self
    }

    @discardableResult
    func assertGetStartedButtonExists() -> Self {
        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 2),
                      "Expected get started button to exist")
        return self
    }

    @discardableResult
    func assertSkipButtonExists() -> Self {
        XCTAssertTrue(skipButton.waitForExistence(timeout: 2),
                      "Expected skip button to exist")
        return self
    }
}
