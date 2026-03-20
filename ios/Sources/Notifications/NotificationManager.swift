//
//  NotificationManager.swift
//  MyApp
//
//  @Observable wrapper around UNUserNotificationCenter.
//  Provides authorization status tracking and permission request.
//

import Foundation
import UserNotifications

@Observable @MainActor
final class NotificationManager {

    // MARK: - Singleton

    static let shared = NotificationManager()

    // MARK: - State

    /// Whether the user has authorized notifications
    var isAuthorized: Bool = false

    /// Current authorization status from the system
    var authorizationStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - Initialization

    private init() {
        Task { await checkAuthorizationStatus() }
    }

    // MARK: - Authorization

    /// Refresh the current authorization status from the notification center
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }

    /// Request notification authorization from the user
    /// - Returns: Whether permission was granted
    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            authorizationStatus = granted ? .authorized : .denied
            return granted
        } catch {
            debugPrint("Notification authorization error: \(error)")
            return false
        }
    }
}
