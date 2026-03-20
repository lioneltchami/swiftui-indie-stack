//
//  SettingsPage.swift
//  MyAppUITests
//
//  Page Object Model for the SettingsView.
//  Encapsulates element queries and user interaction methods.
//

import XCTest

struct SettingsPage {
    let app: XCUIApplication

    // MARK: - Elements

    var signInLink: XCUIElement {
        app.buttons["settings_sign_in"]
    }

    var signOutButton: XCUIElement {
        app.buttons["settings_sign_out"]
    }

    var themePicker: XCUIElement {
        app.otherElements["settings_theme_picker"]
    }

    var manageSubscription: XCUIElement {
        app.buttons["settings_manage_subscription"]
    }

    var restorePurchases: XCUIElement {
        app.buttons["settings_restore_purchases"]
    }

    // MARK: - Tab Navigation

    var settingsTab: XCUIElement {
        app.buttons["tab_settings"]
    }

    // MARK: - Actions

    @discardableResult
    func tapSignIn() -> Self {
        signInLink.tap()
        return self
    }

    @discardableResult
    func tapSignOut() -> Self {
        signOutButton.tap()
        return self
    }

    @discardableResult
    func tapManageSubscription() -> Self {
        manageSubscription.tap()
        return self
    }

    @discardableResult
    func tapRestorePurchases() -> Self {
        restorePurchases.tap()
        return self
    }

    @discardableResult
    func tapSettingsTab() -> Self {
        settingsTab.tap()
        return self
    }

    // MARK: - Assertions

    @discardableResult
    func assertThemePickerExists() -> Self {
        XCTAssertTrue(themePicker.waitForExistence(timeout: 2),
                      "Expected theme picker to exist")
        return self
    }

    @discardableResult
    func assertManageSubscriptionExists() -> Self {
        XCTAssertTrue(manageSubscription.waitForExistence(timeout: 2),
                      "Expected manage subscription button to exist")
        return self
    }
}
