import Foundation
@testable import MyApp

final class MockFirestoreService: FirestoreServiceProtocol {

    // MARK: - Configurable State

    var isAvailable: Bool = false

    // MARK: - In-Memory Data

    var storedSettings: [String: Any] = [:]
    var loggedActivities: [(type: String, date: Date)] = []

    // MARK: - Configurable Behavior

    var getUserSettingsResult: [String: Any] = [:]

    // MARK: - Call Tracking

    var refreshUserCollectionCallCount = 0
    var saveUserSettingsCallCount = 0
    var saveUserSettingsLastData: [String: Any]?
    var getUserSettingsCallCount = 0
    var logActivityCallCount = 0
    var logActivityLastType: String?

    // MARK: - Protocol Conformance

    func refreshUserCollection() {
        refreshUserCollectionCallCount += 1
    }

    func saveUserSettings(settingsData: [String: Any]) {
        saveUserSettingsCallCount += 1
        saveUserSettingsLastData = settingsData
        storedSettings = settingsData
    }

    func getUserSettings() async -> [String: Any] {
        getUserSettingsCallCount += 1
        return getUserSettingsResult
    }

    func logActivity(type: String) {
        logActivityCallCount += 1
        logActivityLastType = type
        loggedActivities.append((type: type, date: Date()))
    }
}
