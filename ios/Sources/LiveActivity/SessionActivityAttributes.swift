//
//  SessionActivityAttributes.swift
//  MyApp
//
//  Defines the attributes and content state for Live Activity session tracking.
//  Used with ActivityKit to show active sessions on the Lock Screen and Dynamic Island.
//

import ActivityKit

struct SessionActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedMinutes: Int
        var goalName: String
        var streakCount: Int
    }

    var sessionStartTime: Date
    var targetDurationMinutes: Int
}
