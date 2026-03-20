import Foundation
@testable import MyApp

enum TestData {
    static func makeStreakData(
        currentStreak: Int = 5,
        bestStreak: Int = 10,
        lastActivityDate: Date? = Date(),
        isAtRisk: Bool = false,
        freezesAvailable: Int = 0,
        freezeActive: Bool = false,
        activeDays: [Date] = [],
        freezesUsedThisPeriod: Int = 0,
        streakRepairable: Bool = false,
        lastStreakBeforeBreak: Int? = nil
    ) -> StreakData {
        StreakData(
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            lastActivityDate: lastActivityDate,
            streakStartDate: Calendar.current.date(byAdding: .day, value: -currentStreak, to: Date()),
            isAtRisk: isAtRisk,
            freezesAvailable: freezesAvailable,
            freezeActive: freezeActive,
            activeDays: activeDays,
            freezesUsedThisPeriod: freezesUsedThisPeriod,
            streakRepairable: streakRepairable,
            lastStreakBeforeBreak: lastStreakBeforeBreak
        )
    }

    static func makeLibraryEntry(
        id: String = "test-entry",
        title: String = "Test Article",
        category: String = "getting_started",
        featured: Bool = false,
        publishDate: Date = Date()
    ) -> LibraryEntry {
        LibraryEntry(
            id: id,
            title: title,
            summary: "Test summary for \(title)",
            contentURL: "https://example.com/content/\(id).md",
            publishDate: publishDate,
            expiryDate: nil,
            category: category,
            imageURL: nil,
            featured: featured,
            version: "1.0"
        )
    }

    /// Create a date relative to today
    static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Calendar.current.startOfDay(for: Date()))!
    }

    /// Create a date for a specific day offset from today at start of day
    static func dayStart(offsetFromToday days: Int) -> Date {
        Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: days, to: Date())!)
    }
}
