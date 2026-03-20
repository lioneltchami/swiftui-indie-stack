import Foundation
@testable import MyApp

@MainActor
final class MockErrorHandler {

    // MARK: - Tracked State

    var currentError: AppError?
    var isAlertPresented: Bool = false
    var toastMessage: String?
    var isToastPresented: Bool = false

    // MARK: - Call Tracking

    var handleCallCount = 0
    var handleLastError: Error?
    var showToastCallCount = 0
    var showToastLastMessage: String?

    // MARK: - Recorded History

    var handledErrors: [Error] = []
    var toastMessages: [String] = []

    // MARK: - Methods

    func handle(_ error: Error) {
        handleCallCount += 1
        handleLastError = error
        handledErrors.append(error)

        if let appError = error as? AppError {
            currentError = appError
        } else {
            currentError = .unknown(error)
        }
        isAlertPresented = true
    }

    func showToast(_ message: String) {
        showToastCallCount += 1
        showToastLastMessage = message
        toastMessages.append(message)
        toastMessage = message
        isToastPresented = true
    }
}
