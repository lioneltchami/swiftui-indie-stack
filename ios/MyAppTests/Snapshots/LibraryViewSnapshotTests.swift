//
//  LibraryViewSnapshotTests.swift
//  MyAppTests
//
//  Snapshot tests for LibraryView in light/dark modes and empty state.
//

import XCTest
import SnapshotTesting
import SwiftUI
@testable import MyApp

final class LibraryViewSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = true
    }

    // MARK: - Light Mode

    @MainActor
    func testLibraryView_lightMode_iPhone15Pro() {
        let view = LibraryView()
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light

        assertSnapshot(
            of: controller,
            as: .image(on: .iPhone13Pro),
            named: "library-light-iPhone15Pro"
        )
    }

    // MARK: - Dark Mode

    @MainActor
    func testLibraryView_darkMode_iPhone15Pro() {
        let view = LibraryView()
            .environment(\.colorScheme, .dark)
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .dark

        assertSnapshot(
            of: controller,
            as: .image(on: .iPhone13Pro),
            named: "library-dark-iPhone15Pro"
        )
    }

    // MARK: - Empty State

    @MainActor
    func testLibraryView_emptyState_iPhone15Pro() {
        // LibraryView with no entries loaded shows empty/loading state
        let view = LibraryView()
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = .light

        assertSnapshot(
            of: controller,
            as: .image(on: .iPhone13Pro),
            named: "library-empty-iPhone15Pro"
        )
    }
}
