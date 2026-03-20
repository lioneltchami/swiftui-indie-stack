//
//  LaunchPerformanceTests.swift
//  MyApp
//
//  Performance baseline tests for app launch time and memory usage.
//  These are UI tests that require the app to be built and a simulator running.
//
//  Reference device for baselines: iPhone 15 Pro Simulator
//
//  To set baselines:
//  1. Run each test once to establish the initial measurement
//  2. Xcode will prompt you to set the baseline value
//  3. Subsequent runs will compare against the baseline
//

import XCTest

final class LaunchPerformanceTests: XCTestCase {

    func testColdLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    func testMemoryBaseline() throws {
        let app = XCUIApplication()
        app.launch()

        measure(metrics: [XCTMemoryMetric(application: app)]) {
            // Navigate through main tabs
            // Tab 0 is already visible (Home)
            app.buttons["Library"].tap()
            app.buttons["Settings"].tap()
            app.buttons["Home"].tap()
        }
    }
}
