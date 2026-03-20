//
//  NotificationSchedulerTests.swift
//  MyAppTests
//
//  Tests for NotificationScheduler streak reminders and milestone notifications.
//

import Testing
import UserNotifications
@testable import MyApp

@Suite("NotificationScheduler Tests")
struct NotificationSchedulerTests {

    // MARK: - Streak Reminders

    @Test("scheduleStreakReminder creates a notification request")
    func scheduleStreakReminderCreatesRequest() async {
        // Schedule a streak reminder
        NotificationScheduler.scheduleStreakReminder(streakCount: 5, preferredHour: 20)

        // Allow a brief moment for the async add to complete
        try? await Task.sleep(nanoseconds: 200_000_000)

        let center = UNUserNotificationCenter.current()
        let pendingRequests = await center.pendingNotificationRequests()
        let streakRequest = pendingRequests.first(where: { $0.identifier == "streak_reminder" })

        #expect(streakRequest != nil, "Expected a pending streak_reminder notification request")

        if let request = streakRequest {
            #expect(request.content.categoryIdentifier == "streak_reminder")
            #expect(request.trigger is UNCalendarNotificationTrigger)

            if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger {
                #expect(calendarTrigger.dateComponents.hour == 20)
                #expect(calendarTrigger.repeats == true)
            }
        }

        // Cleanup
        center.removePendingNotificationRequests(withIdentifiers: ["streak_reminder"])
    }

    @Test("cancelStreakReminders removes pending requests")
    func cancelStreakRemindersRemovesPending() async {
        // Schedule first, then cancel
        NotificationScheduler.scheduleStreakReminder(streakCount: 3)
        try? await Task.sleep(nanoseconds: 200_000_000)

        NotificationScheduler.cancelStreakReminders()
        try? await Task.sleep(nanoseconds: 200_000_000)

        let center = UNUserNotificationCenter.current()
        let pendingRequests = await center.pendingNotificationRequests()
        let streakRequest = pendingRequests.first(where: { $0.identifier == "streak_reminder" })

        #expect(streakRequest == nil, "Expected streak_reminder to be removed after cancellation")
    }

    // MARK: - Milestone Congratulations

    @Test("scheduleMilestoneCongrats creates a time-interval trigger")
    func scheduleMilestoneCongratsCreatesTimeIntervalTrigger() async {
        let milestone = 30
        NotificationScheduler.scheduleMilestoneCongrats(milestone: milestone)

        try? await Task.sleep(nanoseconds: 200_000_000)

        let center = UNUserNotificationCenter.current()
        let pendingRequests = await center.pendingNotificationRequests()
        let milestoneRequest = pendingRequests.first(where: { $0.identifier == "milestone_\(milestone)" })

        #expect(milestoneRequest != nil, "Expected a pending milestone notification request")

        if let request = milestoneRequest {
            #expect(request.trigger is UNTimeIntervalNotificationTrigger)

            if let timeTrigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                // 12 hours = 43200 seconds
                #expect(timeTrigger.timeInterval == 12 * 3600)
                #expect(timeTrigger.repeats == false)
            }
        }

        // Cleanup
        center.removePendingNotificationRequests(withIdentifiers: ["milestone_\(milestone)"])
    }
}
