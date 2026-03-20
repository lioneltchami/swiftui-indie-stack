//
//  LibraryPage.swift
//  MyAppUITests
//
//  Page Object Model for the LibraryView.
//  Encapsulates element queries and user interaction methods.
//

import XCTest

struct LibraryPage {
    let app: XCUIApplication

    // MARK: - Elements

    var searchButton: XCUIElement {
        app.buttons["library_search_button"]
    }

    var refreshButton: XCUIElement {
        app.buttons["library_refresh_button"]
    }

    var searchField: XCUIElement {
        app.searchFields["library_search_field"]
    }

    var categoryFilter: XCUIElement {
        app.otherElements["library_category_filter"]
    }

    func entryRow(_ id: String) -> XCUIElement {
        app.otherElements["library_entry_\(id)"]
    }

    // MARK: - Tab Navigation

    var libraryTab: XCUIElement {
        app.buttons["tab_library"]
    }

    // MARK: - Actions

    @discardableResult
    func tapSearchButton() -> Self {
        searchButton.tap()
        return self
    }

    @discardableResult
    func tapRefreshButton() -> Self {
        refreshButton.tap()
        return self
    }

    @discardableResult
    func tapLibraryTab() -> Self {
        libraryTab.tap()
        return self
    }

    @discardableResult
    func typeSearchText(_ text: String) -> Self {
        searchField.tap()
        searchField.typeText(text)
        return self
    }

    // MARK: - Assertions

    @discardableResult
    func assertSearchButtonExists() -> Self {
        XCTAssertTrue(searchButton.waitForExistence(timeout: 2),
                      "Expected search button to exist")
        return self
    }

    @discardableResult
    func assertSearchFieldExists() -> Self {
        XCTAssertTrue(searchField.waitForExistence(timeout: 2),
                      "Expected search field to exist")
        return self
    }

    @discardableResult
    func assertRefreshButtonExists() -> Self {
        XCTAssertTrue(refreshButton.waitForExistence(timeout: 2),
                      "Expected refresh button to exist")
        return self
    }
}
