//
//  ScrollPerformanceTests.swift
//  MyApp
//
//  Performance baseline tests for scroll smoothness in list views.
//  Uses XCTOSSignpostMetric to measure scroll deceleration frame drops.
//
//  These are UI tests that require the app to be built and a simulator running.
//  Reference device for baselines: iPhone 15 Pro Simulator
//

import XCTest

final class ScrollPerformanceTests: XCTestCase {

    func testLibraryScrollPerformance() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to Library tab
        app.buttons["Library"].tap()

        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            let scrollView = app.scrollViews.firstMatch
            scrollView.swipeUp(velocity: .fast)
            scrollView.swipeDown(velocity: .fast)
        }
    }
}
