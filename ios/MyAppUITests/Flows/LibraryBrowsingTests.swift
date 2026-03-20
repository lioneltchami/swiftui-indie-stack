//
//  LibraryBrowsingTests.swift
//  MyAppUITests
//
//  UI tests for library browsing, search, and filtering interactions.
//

import XCTest

final class LibraryBrowsingTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Search Tests

    /// Test that tapping the search button reveals the search field.
    func testTapSearchButtonShowsSearchField() throws {
        app.launchForTesting()
        let library = LibraryPage(app: app)

        // Navigate to library tab
        library.tapLibraryTab()

        // Tap search button to show search field
        library
            .assertSearchButtonExists()
            .tapSearchButton()

        // Verify search field appears
        library.assertSearchFieldExists()
    }

    // MARK: - Tab Navigation Tests

    /// Test that tapping the library tab shows library content.
    func testTapLibraryTabShowsLibraryContent() throws {
        app.launchForTesting()
        let library = LibraryPage(app: app)

        // Navigate to library tab
        library.tapLibraryTab()

        // Verify library view is displayed by checking for the search button
        // (the search button is always present in the library toolbar)
        library.assertSearchButtonExists()
    }
}
