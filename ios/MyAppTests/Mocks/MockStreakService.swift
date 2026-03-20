import Foundation
@testable import MyApp

@MainActor
final class MockStreakService: StreakServiceProtocol {

    // MARK: - Configurable State

    var streakData: StreakData = .empty
    var isLoading: Bool = false
    var isEnabled: Bool = true

    // MARK: - Computed Properties

    var hasStreak: Bool { streakData.currentStreak > 0 }
    var isMilestone: Bool { streakData.isMilestone }
    var streakText: String { "\(streakData.currentStreak) days" }

    // MARK: - Call Tracking

    var startListeningCallCount = 0
    var startListeningLastUserId: String?
    var stopListeningCallCount = 0
    var updateFromFirestoreCallCount = 0
    var updateFromFirestoreLastData: [String: Any]?
    var recordLocalActivityCallCount = 0
    var useFreezeCallCount = 0
    var repairStreakCallCount = 0

    // MARK: - Protocol Conformance

    func startListening(userId: String) {
        startListeningCallCount += 1
        startListeningLastUserId = userId
    }

    func stopListening() {
        stopListeningCallCount += 1
    }

    func updateFromFirestore(_ data: [String: Any]) {
        updateFromFirestoreCallCount += 1
        updateFromFirestoreLastData = data
    }

    func recordLocalActivity() {
        recordLocalActivityCallCount += 1
    }

    func useFreeze() {
        useFreezeCallCount += 1
    }

    func repairStreak() {
        repairStreakCallCount += 1
    }
}
