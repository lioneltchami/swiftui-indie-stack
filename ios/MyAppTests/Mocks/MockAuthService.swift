import Foundation
@testable import MyApp

@MainActor
final class MockAuthService: AuthServiceProtocol {

    // MARK: - Configurable State

    var authState: AuthState = .authenticated
    var isCheckingAuth: Bool = false
    var userId: String = "test-user-id"
    var isAnonymous: Bool = true
    var canSignIn: Bool = false

    // MARK: - Call Tracking

    var handleInitialAuthenticationCallCount = 0
    var signInAnonymouslyCallCount = 0
    var signOutCallCount = 0

    // MARK: - Configurable Errors

    var signInAnonymouslyError: Error?

    // MARK: - Protocol Conformance

    func handleInitialAuthentication() async {
        handleInitialAuthenticationCallCount += 1
    }

    func signInAnonymously() async throws {
        signInAnonymouslyCallCount += 1
        if let error = signInAnonymouslyError {
            throw error
        }
        authState = .authenticated
        isAnonymous = true
    }

    func signOut() {
        signOutCallCount += 1
        authState = .signedOut
    }
}
