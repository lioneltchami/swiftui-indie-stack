//
//  FirestoreServiceProtocol.swift
//  MyApp
//
//  Protocol abstraction for FirestoreManager.
//  No Firebase-specific types are exposed (Firestore, Auth, Timestamp, etc.).
//  All methods use Swift-native types only.
//

import Foundation

protocol FirestoreServiceProtocol: AnyObject {

    // MARK: - Availability

    /// Whether Firestore is available and enabled for the current configuration
    var isAvailable: Bool { get }

    // MARK: - User Collection

    /// Refresh user data from Firestore after authentication.
    /// Restores settings, streak data, and updates user metadata.
    func refreshUserCollection()

    // MARK: - Settings

    /// Save user settings to Firestore
    /// - Parameter settingsData: Dictionary of settings key-value pairs
    func saveUserSettings(settingsData: [String: Any])

    /// Get user settings from Firestore
    /// - Returns: Dictionary of settings key-value pairs, or empty if unavailable
    func getUserSettings() async -> [String: Any]

    // MARK: - Activity Logging

    /// Log user activity for backend streak calculation
    /// - Parameter type: Activity type string (default: "app_open")
    func logActivity(type: String)
}

// MARK: - Default Parameter Values

extension FirestoreServiceProtocol {

    func logActivity() {
        logActivity(type: "app_open")
    }
}
