import Testing
@testable import MyApp

@Suite("ErrorHandler Tests")
@MainActor
struct ErrorHandlerTests {

    // MARK: - Error Handling

    @Test("handle() sets currentError and presents alert")
    func handleSetsErrorAndPresentsAlert() async {
        let handler = ErrorHandler()
        handler.handle(AppError.networkUnavailable)

        #expect(handler.currentError != nil)
        #expect(handler.isAlertPresented == true)
    }

    @Test("handle() wraps non-AppError in unknown case")
    func handleWrapsUnknownError() async {
        let handler = ErrorHandler()
        let nsError = NSError(domain: "test", code: 42, userInfo: nil)
        handler.handle(nsError)

        #expect(handler.isAlertPresented == true)
        #expect(handler.currentError != nil)
        // Verify it was wrapped as .unknown
        if case .unknown = handler.currentError {
            // Expected
        } else {
            #expect(Bool(false), "Expected error to be wrapped as .unknown")
        }
    }

    @Test("handle() preserves AppError type")
    func handlePreservesAppError() async {
        let handler = ErrorHandler()
        let authError = AppError.authFailed(reason: "bad credentials")
        handler.handle(authError)

        if case .authFailed(let reason) = handler.currentError {
            #expect(reason == "bad credentials")
        } else {
            #expect(Bool(false), "Expected .authFailed error")
        }
    }

    // MARK: - Toast

    @Test("showToast() sets toast message and presents")
    func showToastPresents() async {
        let handler = ErrorHandler()
        handler.showToast("Success!")

        #expect(handler.toastMessage == "Success!")
        #expect(handler.isToastPresented == true)
    }

    @Test("showToast() with different messages updates state")
    func showToastUpdatesMessage() async {
        let handler = ErrorHandler()
        handler.showToast("First message")
        #expect(handler.toastMessage == "First message")

        handler.showToast("Second message")
        #expect(handler.toastMessage == "Second message")
        #expect(handler.isToastPresented == true)
    }

    // MARK: - Initial State

    @Test("ErrorHandler starts with no error and no toast")
    func initialState() async {
        let handler = ErrorHandler()

        #expect(handler.currentError == nil)
        #expect(handler.isAlertPresented == false)
        #expect(handler.toastMessage == nil)
        #expect(handler.isToastPresented == false)
    }

    // MARK: - AppError Descriptions

    @Test("AppError.networkUnavailable has localized description")
    func networkUnavailableDescription() {
        let error = AppError.networkUnavailable
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("internet") == true)
    }

    @Test("AppError.unknown wraps underlying error description")
    func unknownErrorDescription() {
        let underlying = NSError(domain: "TestDomain", code: 99, userInfo: [
            NSLocalizedDescriptionKey: "Something went wrong"
        ])
        let error = AppError.unknown(underlying)
        #expect(error.errorDescription == "Something went wrong")
    }

    @Test("AppError.decodingError includes context")
    func decodingErrorDescription() {
        let error = AppError.decodingError(context: "missing field 'name'")
        #expect(error.errorDescription?.contains("missing field 'name'") == true)
    }
}
