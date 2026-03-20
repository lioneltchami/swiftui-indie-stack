//
//  SessionActivity.swift
//  MyApp
//
//  Manages Live Activity lifecycle for active goal sessions.
//  Provides start, update, and end methods, plus Lock Screen and Dynamic Island views.
//

import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Live Activity Manager

enum SessionActivityManager {

    /// Start a new Live Activity for an active session.
    /// - Parameters:
    ///   - goalName: The name of the goal being worked on.
    ///   - targetMinutes: Target duration in minutes.
    ///   - streakCount: The user's current streak count.
    /// - Returns: The activity ID if successfully started, nil otherwise.
    @discardableResult
    static func startSession(
        goalName: String,
        targetMinutes: Int = 30,
        streakCount: Int
    ) -> String? {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return nil }

        let attributes = SessionActivityAttributes(
            sessionStartTime: Date(),
            targetDurationMinutes: targetMinutes
        )

        let initialState = SessionActivityAttributes.ContentState(
            elapsedMinutes: 0,
            goalName: goalName,
            streakCount: streakCount
        )

        do {
            let activity = try Activity<SessionActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            return activity.id
        } catch {
            debugPrint("Failed to start Live Activity: \(error.localizedDescription)")
            return nil
        }
    }

    /// Update the Live Activity with new elapsed time.
    /// - Parameters:
    ///   - elapsedMinutes: Minutes elapsed since session start.
    ///   - goalName: The goal name.
    ///   - streakCount: Current streak count.
    static func updateSession(
        elapsedMinutes: Int,
        goalName: String,
        streakCount: Int
    ) {
        let updatedState = SessionActivityAttributes.ContentState(
            elapsedMinutes: elapsedMinutes,
            goalName: goalName,
            streakCount: streakCount
        )

        Task {
            for activity in Activity<SessionActivityAttributes>.activities {
                await activity.update(
                    ActivityContent(state: updatedState, staleDate: nil)
                )
            }
        }
    }

    /// End all active session Live Activities.
    static func endSession() {
        Task {
            for activity in Activity<SessionActivityAttributes>.activities {
                let finalState = activity.content.state
                await activity.end(
                    ActivityContent(state: finalState, staleDate: nil),
                    dismissalPolicy: .default
                )
            }
        }
    }
}

// MARK: - Lock Screen View

struct SessionActivityLockScreenView: View {
    let context: ActivityViewContext<SessionActivityAttributes>

    var body: some View {
        HStack(spacing: 16) {
            // Streak flame icon
            VStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text("\(context.state.streakCount)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(String(
                localized: "live_activity_streak_accessibility \(context.state.streakCount)",
                defaultValue: "Streak: \(context.state.streakCount) days"
            ))

            // Session info
            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.goalName)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption)
                    Text("\(context.state.elapsedMinutes) / \(context.attributes.targetDurationMinutes) min")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Progress ring
            ZStack {
                Circle()
                    .stroke(.quaternary, lineWidth: 4)
                Circle()
                    .trim(from: 0, to: progressFraction)
                    .stroke(.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 44, height: 44)
            .accessibilityLabel(String(
                localized: "live_activity_progress_accessibility",
                defaultValue: "\(Int(progressFraction * 100))% complete"
            ))
        }
        .padding(16)
    }

    private var progressFraction: CGFloat {
        guard context.attributes.targetDurationMinutes > 0 else { return 0 }
        return min(
            CGFloat(context.state.elapsedMinutes) / CGFloat(context.attributes.targetDurationMinutes),
            1.0
        )
    }
}

// MARK: - Dynamic Island Compact Views

struct SessionActivityCompactLeadingView: View {
    let context: ActivityViewContext<SessionActivityAttributes>

    var body: some View {
        Image(systemName: "flame.fill")
            .foregroundStyle(.orange)
            .accessibilityLabel(String(
                localized: "live_activity_flame_icon",
                defaultValue: "Active session"
            ))
    }
}

struct SessionActivityCompactTrailingView: View {
    let context: ActivityViewContext<SessionActivityAttributes>

    var body: some View {
        Text("\(context.state.elapsedMinutes)m")
            .font(.caption.bold())
            .monospacedDigit()
            .accessibilityLabel(String(
                localized: "live_activity_elapsed_accessibility",
                defaultValue: "\(context.state.elapsedMinutes) minutes elapsed"
            ))
    }
}

// MARK: - Dynamic Island Expanded View

struct SessionActivityExpandedView: View {
    let context: ActivityViewContext<SessionActivityAttributes>

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text(context.state.goalName)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text("\(context.state.streakCount) day streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ProgressView(
                value: Double(context.state.elapsedMinutes),
                total: Double(context.attributes.targetDurationMinutes)
            )
            .tint(.green)

            HStack {
                Text("\(context.state.elapsedMinutes) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(context.attributes.targetDurationMinutes) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
    }
}
