import Testing
@testable import MyApp

@Suite("AuthManager Tests")
@MainActor
struct AuthManagerTests {

    // NOTE: AuthManager has private init(), so we test via .shared.
    // With useFirebase = false (default config), we test local mode behavior.

    // MARK: - Local Mode State

    @Test("In local mode, authState is authenticated")
    func localModeAuthState() async {
        let manager = AuthManager.shared
        // In local mode (useFirebase = false), auth state should be .authenticated
        #expect(manager.authState == .authenticated)
    }

    @Test("In local mode, userId returns a non-empty local ID")
    func localModeUserId() async {
        let manager = AuthManager.shared
        #expect(!manager.userId.isEmpty)
    }

    @Test("In local mode, isAnonymous is true")
    func localModeIsAnonymous() async {
        let manager = AuthManager.shared
        // Local mode is always considered anonymous
        #expect(manager.isAnonymous == true)
    }

    @Test("In local mode, canSignIn is false")
    func localModeCanSignIn() async {
        let manager = AuthManager.shared
        // canSignIn requires both useFirebase and enableAuth to be true
        #expect(manager.canSignIn == false)
    }

    @Test("In local mode, isCheckingAuth is false after init")
    func localModeNotCheckingAuth() async {
        let manager = AuthManager.shared
        #expect(manager.isCheckingAuth == false)
    }

    @Test("userId is consistent across multiple accesses")
    func userIdConsistency() async {
        let manager = AuthManager.shared
        let id1 = manager.userId
        let id2 = manager.userId
        #expect(id1 == id2)
    }
}
