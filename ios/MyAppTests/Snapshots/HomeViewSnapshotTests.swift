//
//  HomeViewSnapshotTests.swift
//  MyAppTests
//
//  Snapshot tests for HomeView in light and dark modes.
//

import XCTest
import SnapshotTesting
import SwiftUI
@testable import MyApp

final class HomeViewSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = true
    }

    // MARK: - Light Mode

    @MainActor
    func testHomeView_lightMode_iPhone15Pro() {
        let view = HomeView()
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light

        assertSnapshot(
            of: controller,
            as: .image(on: .iPhone13Pro),
            named: "home-light-iPhone15Pro"
        )
    }

    // MARK: - Dark Mode

    @MainActor
    func testHomeView_darkMode_iPhone15Pro() {
        let view = HomeView()
            .environment(\.colorScheme, .dark)
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .dark

        assertSnapshot(
            of: controller,
            as: .image(on: .iPhone13Pro),
            named: "home-dark-iPhone15Pro"
        )
    }
}
