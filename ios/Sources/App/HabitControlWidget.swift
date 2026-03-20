//
//  HabitControlWidget.swift
//  MyApp
//
//  Control Center widget for quick habit logging (iOS 18+).
//  Uses ControlWidget API to add a button to Control Center that
//  triggers the CompleteGoalIntent without opening the app.
//

import SwiftUI
import WidgetKit
import AppIntents

@available(iOS 18.0, *)
struct LogHabitControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "com.myapp.log-habit") {
            ControlWidgetButton(action: CompleteGoalIntent()) {
                Label(String(localized: "control_log_habit"), systemImage: "checkmark.circle.fill")
            }
        }
        .displayName(String(localized: "control_display_name"))
        .description(String(localized: "control_description"))
    }
}
