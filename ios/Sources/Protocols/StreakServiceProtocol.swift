//
//  StreakServiceProtocol.swift
//  MyApp
//
//  Protocol abstraction for StreakViewModel.
//  Exposes streak data and actions for both Firebase and local modes.
//  Uses the local StreakData model type (no Firebase dependencies).
//

import Foundation

@MainActor
protocol StreakServiceProtocol: AnyObject {

    // MARK: - Observable State

    /// Current streak data (current streak, best streak, active days, etc.)
    var streakData: StreakData { get }

    /// Whether streak data is currently being loaded
    var isLoading: Bool { get }

    // MARK: - Computed Properties

    /// Whether the user has an active streak (currentStreak > 0)
    var hasStreak: Bool { get }

    /// Whether the current streak is a milestone (7, 30, 100, 365, etc.)
    var isMilestone: Bool { get }

    /// Human-readable streak text (e.g., "1 day", "5 days")
    var streakText: String { get }

    /// Whether the streak feature is enabled via AppConfiguration
    var isEnabled: Bool { get }

    // MARK: - Listening (Firebase Mode)

    /// Start listening to streak updates from Firestore
    /// - Parameter userId: The user ID to listen for
    func startListening(userId: String)

    /// Stop listening to Firestore streak updates
    func stopListening()

    /// Update streak data from a Firestore dictionary
    /// - Parameter data: Dictionary of streak fields from Firestore
    func updateFromFirestore(_ data: [String: Any])

    // MARK: - Local Mode

    /// Record a local activity (increments streak in local mode only)
    func recordLocalActivity()

    // MARK: - Freeze & Repair

    /// Use a streak freeze to protect against a missed day
    func useFreeze()

    /// Repair a broken streak by restoring the previous streak count (premium feature)
    func repairStreak()
}
