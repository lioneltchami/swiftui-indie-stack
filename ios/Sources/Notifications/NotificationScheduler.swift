//
//  NotificationScheduler.swift
//  MyApp
//
//  Schedules and manages local notifications for streak reminders
//  and milestone congratulations.
//

import Foundation
import UserNotifications

struct NotificationScheduler {

    // MARK: - Streak Reminders

    /// Schedule a daily streak-at-risk reminder notification.
    /// Fires at the user's preferred hour if no activity has been recorded today.
    /// - Parameters:
    ///   - streakCount: Current streak count to include in the notification body
    ///   - preferredHour: Hour of day (0-23) to send the reminder. Defaults to 20 (8 PM).
    static func scheduleStreakReminder(streakCount: Int, preferredHour: Int = 20) {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification_streak_risk_title")
        content.body = String(localized: "notification_streak_risk_body \(streakCount)")
        content.sound = .default
        content.categoryIdentifier = "streak_reminder"

        var dateComponents = DateComponents()
        dateComponents.hour = preferredHour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "streak_reminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                debugPrint("Failed to schedule streak reminder: \(error)")
            }
        }
    }

    /// Cancel all pending streak reminder notifications
    static func cancelStreakReminders() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["streak_reminder"])
    }

    // MARK: - Milestone Congratulations

    /// Schedule a congratulatory notification after a streak milestone achievement.
    /// Fires 12 hours after the milestone to reinforce the positive behavior.
    /// - Parameter milestone: The milestone value (e.g. 7, 30, 100)
    static func scheduleMilestoneCongrats(milestone: Int) {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification_milestone_title")
        content.body = String(localized: "notification_milestone_body \(milestone)")
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 12 * 3600, // 12 hours later
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "milestone_\(milestone)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                debugPrint("Failed to schedule milestone congrats: \(error)")
            }
        }
    }
}
