import Testing
@testable import MyApp

@Suite("AppRouter Tests")
@MainActor
struct AppRouterTests {

    // MARK: - Initial State

    @Test("Initial paths are empty")
    func initialState() async {
        let router = AppRouter()

        #expect(router.homePath.isEmpty)
        #expect(router.libraryPath.isEmpty)
        #expect(router.settingsPath.isEmpty)
    }

    // MARK: - Navigation: Home

    @Test("navigateHome appends route to homePath")
    func navigateHome() async {
        let router = AppRouter()
        router.navigateHome(to: .streakDetail)

        #expect(router.homePath.count == 1)
    }

    @Test("popToRootHome clears homePath")
    func popToRootHome() async {
        let router = AppRouter()
        router.navigateHome(to: .streakDetail)
        #expect(router.homePath.count == 1)

        router.popToRootHome()
        #expect(router.homePath.isEmpty)
    }

    // MARK: - Navigation: Library

    @Test("Pushing library route appends to path")
    func pushLibraryRoute() async {
        let router = AppRouter()
        let entry = TestData.makeLibraryEntry()
        router.navigateLibrary(to: .articleDetail(entry))

        #expect(router.libraryPath.count == 1)
    }

    @Test("popToRootLibrary clears libraryPath")
    func popToRootLibrary() async {
        let router = AppRouter()
        let entry = TestData.makeLibraryEntry()
        router.navigateLibrary(to: .articleDetail(entry))
        router.popToRootLibrary()

        #expect(router.libraryPath.isEmpty)
    }

    // MARK: - Navigation: Settings

    @Test("navigateSettings appends route to settingsPath")
    func navigateSettings() async {
        let router = AppRouter()
        router.navigateSettings(to: .signIn)

        #expect(router.settingsPath.count == 1)
    }

    @Test("Popping all routes clears settingsPath")
    func popToRootSettings() async {
        let router = AppRouter()
        router.navigateSettings(to: .signIn)
        router.popToRootSettings()

        #expect(router.settingsPath.isEmpty)
    }

    // MARK: - Multiple Routes

    @Test("Multiple pushes create a navigation stack")
    func multipleRoutes() async {
        let router = AppRouter()
        let entry1 = TestData.makeLibraryEntry(id: "entry-1")
        let entry2 = TestData.makeLibraryEntry(id: "entry-2")
        router.navigateLibrary(to: .articleDetail(entry1))
        router.navigateLibrary(to: .articleDetail(entry2))

        #expect(router.libraryPath.count == 2)
    }

    // MARK: - Tab Independence

    @Test("Navigation in one tab does not affect other tabs")
    func tabIndependence() async {
        let router = AppRouter()
        router.navigateHome(to: .streakDetail)
        router.navigateSettings(to: .signIn)

        #expect(router.homePath.count == 1)
        #expect(router.libraryPath.isEmpty)
        #expect(router.settingsPath.count == 1)
    }

    // MARK: - Route Type Coverage

    @Test("HomeRoute.streakDetail is the only home route case")
    func homeRouteStreakDetail() async {
        let router = AppRouter()
        router.navigateHome(to: .streakDetail)
        #expect(router.homePath.first == .streakDetail)
    }

    @Test("SettingsRoute.signIn is the only settings route case")
    func settingsRouteSignIn() async {
        let router = AppRouter()
        router.navigateSettings(to: .signIn)
        #expect(router.settingsPath.first == .signIn)
    }

    @Test("LibraryRoute.articleDetail carries the correct entry")
    func libraryRouteArticleDetailCarriesEntry() async {
        let router = AppRouter()
        let entry = TestData.makeLibraryEntry(id: "abc-123", title: "Specific Title")
        router.navigateLibrary(to: .articleDetail(entry))

        if case .articleDetail(let captured) = router.libraryPath.first {
            #expect(captured.id == "abc-123")
            #expect(captured.title == "Specific Title")
        } else {
            #expect(Bool(false), "Expected articleDetail route")
        }
    }

    @Test("Pop to root on each tab is independent")
    func popToRootIsIndependent() async {
        let router = AppRouter()
        router.navigateHome(to: .streakDetail)
        router.navigateSettings(to: .signIn)
        let entry = TestData.makeLibraryEntry()
        router.navigateLibrary(to: .articleDetail(entry))

        router.popToRootHome()

        #expect(router.homePath.isEmpty)
        #expect(router.libraryPath.count == 1)
        #expect(router.settingsPath.count == 1)
    }
}
