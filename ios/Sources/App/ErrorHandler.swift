//
//  ErrorHandler.swift
//  MyApp
//
//  Centralized error handler that manages user-facing error alerts and
//  non-blocking toast messages. Injected into the SwiftUI environment
//  so any view can report errors consistently.
//
//  Usage:
//  ```swift
//  @Environment(ErrorHandler.self) var errorHandler
//  errorHandler.handle(someError)
//  errorHandler.showToast("Saved successfully")
//  ```
//

import Observation
import Foundation

@Observable @MainActor
final class ErrorHandler {

    // MARK: - Alert State

    /// The current error to display in an alert
    var currentError: AppError?

    /// Whether the error alert is currently presented
    var isAlertPresented = false

    // MARK: - Toast State

    /// The message to display in a non-blocking toast overlay
    var toastMessage: String?

    /// Whether the toast overlay is currently visible
    var isToastPresented = false

    // MARK: - Error Handling

    /// Convert any `Error` to an `AppError` and present it as an alert.
    /// Also tracks the error via Analytics for monitoring.
    func handle(_ error: Error) {
        if let appError = error as? AppError {
            currentError = appError
        } else {
            currentError = .unknown(error)
        }
        isAlertPresented = true
        Analytics.trackError(
            String(describing: currentError),
            message: currentError?.errorDescription
        )
    }

    /// Show a brief, non-blocking toast message (e.g. success confirmations).
    func showToast(_ message: String) {
        toastMessage = message
        isToastPresented = true
    }
}
