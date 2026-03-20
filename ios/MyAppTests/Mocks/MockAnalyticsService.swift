import Foundation
@testable import MyApp

final class MockAnalyticsService: AnalyticsServiceProtocol {

    // MARK: - Recorded Events

    struct TrackedEvent: Equatable {
        let name: String
        let parameters: [String: String]

        static func == (lhs: TrackedEvent, rhs: TrackedEvent) -> Bool {
            lhs.name == rhs.name && lhs.parameters == rhs.parameters
        }
    }

    var trackedEvents: [TrackedEvent] = []
    var trackedScreenViews: [String] = []
    var trackedButtonTaps: [(buttonName: String, screenName: String?)] = []
    var trackedFeatures: [String] = []
    var trackedErrors: [(errorType: String, message: String?)] = []
    var trackedOnboardingSteps: [(step: Int, stepName: String)] = []
    var trackedSubscriptions: [String] = []

    // MARK: - Call Tracking

    var trackCallCount = 0
    var trackScreenViewCallCount = 0
    var trackButtonTapCallCount = 0
    var trackFeatureUsedCallCount = 0
    var trackErrorCallCount = 0
    var trackOnboardingStepCallCount = 0
    var trackSubscriptionCallCount = 0

    // MARK: - Protocol Conformance

    func track(event: String, parameters: [String: Any]) {
        trackCallCount += 1
        let stringParams = parameters.compactMapValues { "\($0)" }
        trackedEvents.append(TrackedEvent(name: event, parameters: stringParams))
    }

    func trackScreenView(_ screenName: String) {
        trackScreenViewCallCount += 1
        trackedScreenViews.append(screenName)
    }

    func trackButtonTap(_ buttonName: String, on screenName: String?) {
        trackButtonTapCallCount += 1
        trackedButtonTaps.append((buttonName: buttonName, screenName: screenName))
    }

    func trackFeatureUsed(_ featureName: String) {
        trackFeatureUsedCallCount += 1
        trackedFeatures.append(featureName)
    }

    func trackError(_ errorType: String, message: String?) {
        trackErrorCallCount += 1
        trackedErrors.append((errorType: errorType, message: message))
    }

    func trackOnboardingStep(_ step: Int, stepName: String) {
        trackOnboardingStepCallCount += 1
        trackedOnboardingSteps.append((step: step, stepName: stepName))
    }

    func trackSubscription(_ action: String) {
        trackSubscriptionCallCount += 1
        trackedSubscriptions.append(action)
    }
}
