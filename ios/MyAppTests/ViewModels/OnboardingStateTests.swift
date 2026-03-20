import Testing
@testable import MyApp

@Suite("OnboardingState Tests")
@MainActor
struct OnboardingStateTests {

    // MARK: - Initial State

    @Test("Initial state has currentStep of 0")
    func initialCurrentStep() {
        let state = OnboardingState()
        #expect(state.currentStep == 0)
    }

    @Test("Initial state has totalSteps of 5")
    func initialTotalSteps() {
        let state = OnboardingState()
        #expect(state.totalSteps == 5)
    }

    @Test("Initial state has nil selectedGoal")
    func initialSelectedGoal() {
        let state = OnboardingState()
        #expect(state.selectedGoal == nil)
    }

    @Test("Initial state has daily selectedFrequency")
    func initialSelectedFrequency() {
        let state = OnboardingState()
        #expect(state.selectedFrequency == .daily)
    }

    @Test("Initial state has notificationsAccepted as false")
    func initialNotificationsAccepted() {
        let state = OnboardingState()
        #expect(state.notificationsAccepted == false)
    }

    @Test("Initial state has hasCompletedOnboarding as false")
    func initialHasCompletedOnboarding() {
        let state = OnboardingState()
        #expect(state.hasCompletedOnboarding == false)
    }

    // MARK: - Progress Calculation

    @Test("Progress is 0.0 at step 0 of 5")
    func progressAtStepZero() {
        let state = OnboardingState()
        #expect(state.progress == 0.0)
    }

    @Test("Progress is currentStep / totalSteps")
    func progressCalculation() {
        let state = OnboardingState()
        state.currentStep = 3
        // 3 / 5 = 0.6
        #expect(state.progress == 0.6)
    }

    @Test("Progress is 1.0 when currentStep equals totalSteps")
    func progressAtCompletion() {
        let state = OnboardingState()
        state.currentStep = 5
        #expect(state.progress == 1.0)
    }

    @Test("Progress updates when currentStep changes")
    func progressUpdatesWithStep() {
        let state = OnboardingState()

        state.currentStep = 1
        #expect(state.progress == 0.2)

        state.currentStep = 2
        #expect(state.progress == 0.4)

        state.currentStep = 4
        #expect(state.progress == 0.8)
    }

    // MARK: - GoalFrequency Enum

    @Test("GoalFrequency has exactly 3 cases")
    func goalFrequencyCaseCount() {
        let allCases = OnboardingState.GoalFrequency.allCases
        #expect(allCases.count == 3)
    }

    @Test("GoalFrequency cases have expected raw values")
    func goalFrequencyRawValues() {
        #expect(OnboardingState.GoalFrequency.daily.rawValue == "Every day")
        #expect(OnboardingState.GoalFrequency.weekdays.rawValue == "Weekdays only")
        #expect(OnboardingState.GoalFrequency.threePerWeek.rawValue == "3 times per week")
    }

    @Test("GoalFrequency id matches rawValue")
    func goalFrequencyIdMatchesRawValue() {
        for frequency in OnboardingState.GoalFrequency.allCases {
            #expect(frequency.id == frequency.rawValue)
        }
    }

    @Test("GoalFrequency icons are non-empty strings")
    func goalFrequencyIconsExist() {
        for frequency in OnboardingState.GoalFrequency.allCases {
            #expect(!frequency.icon.isEmpty)
        }
    }
}
