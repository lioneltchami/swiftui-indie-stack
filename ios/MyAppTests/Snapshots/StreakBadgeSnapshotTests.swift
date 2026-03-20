//
//  StreakBadgeSnapshotTests.swift
//  MyAppTests
//
//  Snapshot tests for StreakBadgeView at various streak levels.
//

import XCTest
import SnapshotTesting
import SwiftUI
@testable import MyApp

final class StreakBadgeSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = true
    }

    // MARK: - Streak Level Snapshots

    @MainActor
    func testStreakBadge_noStreak() {
        let streakProvider = StreakViewModel.shared
        streakProvider.streakData = StreakData.empty
        let view = StreakBadgeView(streakProvider: streakProvider)
            .frame(width: 120, height: 120)
        let controller = UIHostingController(rootView: view)

        assertSnapshot(
            of: controller,
            as: .image(on: .iPhone13Pro),
            named: "streak-badge-0-days"
        )
    }

    @MainActor
    func testStreakBadge_7dayStreak() {
        let streakProvider = StreakViewModel.shared
        streakProvider.streakData = StreakData(
            currentStreak: 7,
            bestStreak: 7,
            lastActivityDate: Date(),
            streakStartDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()),
            isAtRisk: false,
            freezesAvailable: 0,
            freezeActive: false,
            activeDays: []
        )
        let view = StreakBadgeView(streakProvider: streakProvider)
            .frame(width: 120, height: 120)
        let controller = UIHostingController(rootView: view)

        assertSnapshot(
            of: controller,
            as: .image(on: .iPhone13Pro),
            named: "streak-badge-7-days"
        )
    }

    @MainActor
    func testStreakBadge_30dayStreak() {
        let streakProvider = StreakViewModel.shared
        streakProvider.streakData = StreakData(
            currentStreak: 30,
            bestStreak: 30,
            lastActivityDate: Date(),
            streakStartDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()),
            isAtRisk: false,
            freezesAvailable: 0,
            freezeActive: false,
            activeDays: []
        )
        let view = StreakBadgeView(streakProvider: streakProvider)
            .frame(width: 120, height: 120)
        let controller = UIHostingController(rootView: view)

        assertSnapshot(
            of: controller,
            as: .image(on: .iPhone13Pro),
            named: "streak-badge-30-days"
        )
    }

    @MainActor
    func testStreakBadge_100dayStreak() {
        let streakProvider = StreakViewModel.shared
        streakProvider.streakData = StreakData(
            currentStreak: 100,
            bestStreak: 100,
            lastActivityDate: Date(),
            streakStartDate: Calendar.current.date(byAdding: .day, value: -100, to: Date()),
            isAtRisk: false,
            freezesAvailable: 0,
            freezeActive: false,
            activeDays: []
        )
        let view = StreakBadgeView(streakProvider: streakProvider)
            .frame(width: 120, height: 120)
        let controller = UIHostingController(rootView: view)

        assertSnapshot(
            of: controller,
            as: .image(on: .iPhone13Pro),
            named: "streak-badge-100-days"
        )
    }

    @MainActor
    func testStreakBadge_365dayStreak() {
        let streakProvider = StreakViewModel.shared
        streakProvider.streakData = StreakData(
            currentStreak: 365,
            bestStreak: 365,
            lastActivityDate: Date(),
            streakStartDate: Calendar.current.date(byAdding: .day, value: -365, to: Date()),
            isAtRisk: false,
            freezesAvailable: 0,
            freezeActive: false,
            activeDays: []
        )
        let view = StreakBadgeView(streakProvider: streakProvider)
            .frame(width: 120, height: 120)
        let controller = UIHostingController(rootView: view)

        assertSnapshot(
            of: controller,
            as: .image(on: .iPhone13Pro),
            named: "streak-badge-365-days"
        )
    }
}
