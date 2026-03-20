import Testing
@testable import MyApp

@Suite("StreakViewModel Tests")
@MainActor
struct StreakViewModelTests {

    // NOTE: StreakViewModel has private init(), so we test via .shared
    // and reset state between tests. We also test core logic through
    // StreakData model directly where possible.

    // MARK: - Local Activity Recording

    @Test("Recording first activity starts streak at 1")
    func firstActivityStartsStreak() async {
        let vm = StreakViewModel.shared
        // Reset to empty state
        vm.streakData = .empty
        vm.recordLocalActivity()

        #expect(vm.streakData.currentStreak == 1)
        #expect(vm.streakData.bestStreak == 1)
        #expect(vm.streakData.lastActivityDate != nil)
        #expect(vm.streakData.streakStartDate != nil)
    }

    @Test("Recording activity on consecutive day increments streak")
    func consecutiveDayIncrementsStreak() async {
        let vm = StreakViewModel.shared
        // Simulate yesterday's activity
        vm.streakData = TestData.makeStreakData(
            currentStreak: 3,
            bestStreak: 3,
            lastActivityDate: TestData.daysAgo(1)
        )
        vm.recordLocalActivity()

        #expect(vm.streakData.currentStreak == 4)
        #expect(vm.streakData.bestStreak == 4)
    }

    @Test("Recording activity after missing a day resets streak to 1")
    func missedDayResetsStreak() async {
        let vm = StreakViewModel.shared
        vm.streakData = TestData.makeStreakData(
            currentStreak: 10,
            bestStreak: 15,
            lastActivityDate: TestData.daysAgo(2) // missed yesterday
        )
        vm.recordLocalActivity()

        #expect(vm.streakData.currentStreak == 1)
        #expect(vm.streakData.bestStreak == 15) // best streak preserved
    }

    @Test("Recording activity twice on same day is a no-op")
    func duplicateActivitySameDay() async {
        let vm = StreakViewModel.shared
        vm.streakData = TestData.makeStreakData(
            currentStreak: 5,
            lastActivityDate: Date() // already logged today
        )
        let streakBefore = vm.streakData.currentStreak
        vm.recordLocalActivity()

        #expect(vm.streakData.currentStreak == streakBefore)
    }

    @Test("Best streak updates when current exceeds previous best")
    func bestStreakUpdates() async {
        let vm = StreakViewModel.shared
        vm.streakData = TestData.makeStreakData(
            currentStreak: 5,
            bestStreak: 5,
            lastActivityDate: TestData.daysAgo(1)
        )
        vm.recordLocalActivity()

        #expect(vm.streakData.currentStreak == 6)
        #expect(vm.streakData.bestStreak == 6)
    }

    @Test("Active days window is limited to 31 days")
    func activeDaysWindowedTo31Days() async {
        let vm = StreakViewModel.shared
        let oldDays = (0..<40).map { TestData.daysAgo($0) }
        vm.streakData = TestData.makeStreakData(
            currentStreak: 1,
            lastActivityDate: TestData.daysAgo(1),
            activeDays: oldDays
        )
        vm.recordLocalActivity()

        #expect(vm.streakData.activeDays.count <= 31)
    }

    // MARK: - Computed Properties

    @Test("hasStreak returns true when currentStreak > 0")
    func hasStreakComputed() async {
        let vm = StreakViewModel.shared
        vm.streakData = TestData.makeStreakData(currentStreak: 1)
        #expect(vm.hasStreak == true)

        vm.streakData = TestData.makeStreakData(currentStreak: 0)
        #expect(vm.hasStreak == false)
    }

    @Test("streakText returns correct singular/plural form")
    func streakTextFormatting() async {
        let vm = StreakViewModel.shared
        vm.streakData = TestData.makeStreakData(currentStreak: 1)
        #expect(vm.streakText == "1 day")

        vm.streakData = TestData.makeStreakData(currentStreak: 7)
        #expect(vm.streakText == "7 days")
    }

    @Test("isMilestone detects standard milestones")
    func milestoneDetection() async {
        let vm = StreakViewModel.shared
        for milestone in [7, 30, 50, 100, 200, 365, 500, 1000] {
            vm.streakData = TestData.makeStreakData(currentStreak: milestone)
            #expect(vm.isMilestone == true, "Expected \(milestone) to be a milestone")
        }

        vm.streakData = TestData.makeStreakData(currentStreak: 8)
        #expect(vm.isMilestone == false)
    }

    @Test("streakText returns plural for zero days")
    func streakTextZeroDays() async {
        let vm = StreakViewModel.shared
        vm.streakData = TestData.makeStreakData(currentStreak: 0)
        #expect(vm.streakText == "0 days")
    }

    @Test("Best streak is preserved when streak resets")
    func bestStreakPreservedOnReset() async {
        let vm = StreakViewModel.shared
        vm.streakData = TestData.makeStreakData(
            currentStreak: 5,
            bestStreak: 20,
            lastActivityDate: TestData.daysAgo(3) // missed multiple days
        )
        vm.recordLocalActivity()

        #expect(vm.streakData.currentStreak == 1)
        #expect(vm.streakData.bestStreak == 20)
    }

    // MARK: - Freeze Tests

    @Test("useFreeze decrements freezesAvailable")
    func useFreezeDecrementsFreezes() async {
        let vm = StreakViewModel.shared
        vm.streakData = TestData.makeStreakData(
            currentStreak: 5,
            bestStreak: 5,
            lastActivityDate: TestData.daysAgo(2),
            isAtRisk: true,
            freezesAvailable: 3,
            freezesUsedThisPeriod: 0
        )
        vm.useFreeze()

        #expect(vm.streakData.freezesAvailable == 2)
        #expect(vm.streakData.freezeActive == true)
        #expect(vm.streakData.freezesUsedThisPeriod == 1)
        #expect(vm.streakData.isAtRisk == false)
    }

    @Test("useFreeze with zero freezes is no-op")
    func useFreezeWithZeroFreezesIsNoop() async {
        let vm = StreakViewModel.shared
        vm.streakData = TestData.makeStreakData(
            currentStreak: 5,
            bestStreak: 5,
            lastActivityDate: TestData.daysAgo(2),
            isAtRisk: true,
            freezesAvailable: 0
        )
        let dataBefore = vm.streakData
        vm.useFreeze()

        #expect(vm.streakData.freezesAvailable == dataBefore.freezesAvailable)
        #expect(vm.streakData.freezeActive == dataBefore.freezeActive)
        #expect(vm.streakData.currentStreak == dataBefore.currentStreak)
    }

    // MARK: - Repair Tests

    @Test("repairStreak restores lastStreakBeforeBreak")
    func repairStreakRestoresPreviousStreak() async {
        let vm = StreakViewModel.shared
        vm.streakData = TestData.makeStreakData(
            currentStreak: 1,
            bestStreak: 10,
            lastActivityDate: TestData.daysAgo(0),
            streakRepairable: true,
            lastStreakBeforeBreak: 10
        )
        vm.repairStreak()

        #expect(vm.streakData.currentStreak == 10)
        #expect(vm.streakData.bestStreak == 10)
        #expect(vm.streakData.streakRepairable == false)
        #expect(vm.streakData.lastStreakBeforeBreak == nil)
    }

    @Test("repairStreak with no previous streak is no-op")
    func repairStreakWithNoPreviousStreakIsNoop() async {
        let vm = StreakViewModel.shared
        vm.streakData = TestData.makeStreakData(
            currentStreak: 1,
            bestStreak: 5,
            lastActivityDate: TestData.daysAgo(0),
            streakRepairable: false,
            lastStreakBeforeBreak: nil
        )
        let streakBefore = vm.streakData.currentStreak
        vm.repairStreak()

        #expect(vm.streakData.currentStreak == streakBefore)
        #expect(vm.streakData.streakRepairable == false)
    }

    @Test("Auto-freeze during recordLocalActivity when streak would break")
    func autoFreezeDuringRecordActivity() async {
        let vm = StreakViewModel.shared
        // Streak of 5, missed yesterday, but has freezes available
        vm.streakData = TestData.makeStreakData(
            currentStreak: 5,
            bestStreak: 5,
            lastActivityDate: TestData.daysAgo(2),
            freezesAvailable: 2,
            freezesUsedThisPeriod: 0
        )
        vm.recordLocalActivity()

        // Auto-freeze should have been used, streak preserved and incremented
        #expect(vm.streakData.currentStreak == 6)
        #expect(vm.streakData.freezesAvailable == 1)
        #expect(vm.streakData.freezesUsedThisPeriod == 1)
        #expect(vm.streakData.freezeActive == true)
    }
}
