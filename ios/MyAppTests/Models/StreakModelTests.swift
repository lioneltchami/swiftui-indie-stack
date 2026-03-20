import Testing
@testable import MyApp

@Suite("StreakData Model Tests")
struct StreakModelTests {

    // MARK: - Milestone Detection

    @Test("isMilestone returns true for all standard milestones")
    func milestoneValues() {
        for milestone in StreakData.milestones {
            let data = StreakData(
                currentStreak: milestone, bestStreak: milestone,
                lastActivityDate: nil, streakStartDate: nil,
                isAtRisk: false, freezesAvailable: 0,
                freezeActive: false, activeDays: []
            )
            #expect(data.isMilestone == true, "Expected \(milestone) to be a milestone")
        }
    }

    @Test("isMilestone returns false for non-milestone values")
    func nonMilestoneValues() {
        let nonMilestones = [0, 1, 2, 5, 8, 15, 29, 31, 99, 101, 364, 366, 999]
        for value in nonMilestones {
            let data = StreakData(
                currentStreak: value, bestStreak: value,
                lastActivityDate: nil, streakStartDate: nil,
                isAtRisk: false, freezesAvailable: 0,
                freezeActive: false, activeDays: []
            )
            #expect(data.isMilestone == false, "Expected \(value) to NOT be a milestone")
        }
    }

    // MARK: - Next Milestone

    @Test("nextMilestone returns correct next target")
    func nextMilestoneCalculation() {
        let data = StreakData(
            currentStreak: 15, bestStreak: 15,
            lastActivityDate: nil, streakStartDate: nil,
            isAtRisk: false, freezesAvailable: 0,
            freezeActive: false, activeDays: []
        )
        #expect(data.nextMilestone == 30)
    }

    @Test("nextMilestone returns 7 for streak of 0")
    func nextMilestoneFromZero() {
        let data = StreakData(
            currentStreak: 0, bestStreak: 0,
            lastActivityDate: nil, streakStartDate: nil,
            isAtRisk: false, freezesAvailable: 0,
            freezeActive: false, activeDays: []
        )
        #expect(data.nextMilestone == 7)
    }

    @Test("nextMilestone returns nil when past all milestones")
    func nextMilestonePastAll() {
        let data = StreakData(
            currentStreak: 1500, bestStreak: 1500,
            lastActivityDate: nil, streakStartDate: nil,
            isAtRisk: false, freezesAvailable: 0,
            freezeActive: false, activeDays: []
        )
        #expect(data.nextMilestone == nil)
    }

    // MARK: - Progress to Next Milestone

    @Test("progressToNextMilestone returns correct fraction")
    func progressCalculation() {
        let data = StreakData(
            currentStreak: 15, bestStreak: 15,
            lastActivityDate: nil, streakStartDate: nil,
            isAtRisk: false, freezesAvailable: 0,
            freezeActive: false, activeDays: []
        )
        // Between 7 and 30: (15-7)/(30-7) = 8/23 ~= 0.347
        let progress = data.progressToNextMilestone
        #expect(progress > 0.3 && progress < 0.4)
    }

    @Test("progressToNextMilestone returns 1.0 when past all milestones")
    func progressPastAllMilestones() {
        let data = StreakData(
            currentStreak: 2000, bestStreak: 2000,
            lastActivityDate: nil, streakStartDate: nil,
            isAtRisk: false, freezesAvailable: 0,
            freezeActive: false, activeDays: []
        )
        #expect(data.progressToNextMilestone == 1.0)
    }

    @Test("progressToNextMilestone at zero streak")
    func progressAtZero() {
        let data = StreakData(
            currentStreak: 0, bestStreak: 0,
            lastActivityDate: nil, streakStartDate: nil,
            isAtRisk: false, freezesAvailable: 0,
            freezeActive: false, activeDays: []
        )
        // Between 0 and 7: (0-0)/(7-0) = 0.0
        #expect(data.progressToNextMilestone == 0.0)
    }

    // MARK: - Empty Static Property

    @Test("empty static property has all zero/nil values")
    func emptyStreakData() {
        let data = StreakData.empty
        #expect(data.currentStreak == 0)
        #expect(data.bestStreak == 0)
        #expect(data.lastActivityDate == nil)
        #expect(data.streakStartDate == nil)
        #expect(data.isAtRisk == false)
        #expect(data.freezesAvailable == 0)
        #expect(data.freezeActive == false)
        #expect(data.activeDays.isEmpty)
    }

    // MARK: - Engagement Enhancement Fields

    @Test("New fields have correct defaults when using backward-compatible init")
    func newFieldsHaveCorrectDefaults() {
        let data = StreakData(
            currentStreak: 5,
            bestStreak: 5,
            lastActivityDate: nil,
            streakStartDate: nil,
            isAtRisk: false,
            freezesAvailable: 0,
            freezeActive: false,
            activeDays: []
        )
        #expect(data.freezesUsedThisPeriod == 0)
        #expect(data.streakRepairable == false)
        #expect(data.lastStreakBeforeBreak == nil)
    }

    @Test("StreakData.empty includes new fields as zero/false/nil")
    func emptyIncludesNewFields() {
        let data = StreakData.empty
        #expect(data.freezesUsedThisPeriod == 0)
        #expect(data.streakRepairable == false)
        #expect(data.lastStreakBeforeBreak == nil)
    }

    @Test("Full initializer sets all engagement fields correctly")
    func fullInitializerSetsEngagementFields() {
        let data = StreakData(
            currentStreak: 1,
            bestStreak: 10,
            lastActivityDate: nil,
            streakStartDate: nil,
            isAtRisk: false,
            freezesAvailable: 2,
            freezeActive: true,
            activeDays: [],
            freezesUsedThisPeriod: 3,
            streakRepairable: true,
            lastStreakBeforeBreak: 10
        )
        #expect(data.freezesUsedThisPeriod == 3)
        #expect(data.streakRepairable == true)
        #expect(data.lastStreakBeforeBreak == 10)
    }
}
