import Testing
@testable import MyApp

@Suite("LibraryViewModel Tests")
@MainActor
struct LibraryViewModelTests {

    // MARK: - Filtering by Category

    @Test("filterEntries filters by selected category")
    func filterByCategory() async {
        let vm = LibraryViewModel()
        vm.entries = [
            TestData.makeLibraryEntry(id: "1", category: "getting_started"),
            TestData.makeLibraryEntry(id: "2", category: "features"),
            TestData.makeLibraryEntry(id: "3", category: "getting_started"),
        ]
        vm.selectedCategory = "getting_started"
        vm.filterEntries()

        #expect(vm.filteredEntries.count == 2)
        #expect(vm.filteredEntries.allSatisfy { $0.category == "getting_started" })
    }

    // MARK: - Filtering by Search Text

    @Test("filterEntries filters by search text across title and summary")
    func filterBySearchText() async {
        let vm = LibraryViewModel()
        vm.entries = [
            TestData.makeLibraryEntry(id: "1", title: "Getting Started Guide"),
            TestData.makeLibraryEntry(id: "2", title: "Advanced Features"),
            TestData.makeLibraryEntry(id: "3", title: "Getting Help"),
        ]
        vm.searchText = "getting"
        vm.filterEntries()

        #expect(vm.filteredEntries.count == 2)
    }

    @Test("filterEntries with empty search returns all entries")
    func emptySearchReturnsAll() async {
        let vm = LibraryViewModel()
        vm.entries = [
            TestData.makeLibraryEntry(id: "1"),
            TestData.makeLibraryEntry(id: "2"),
        ]
        vm.searchText = ""
        vm.selectedCategory = nil
        vm.filterEntries()

        #expect(vm.filteredEntries.count == 2)
    }

    // MARK: - Combined Filters

    @Test("filterEntries combines category and search filters")
    func combinedFilters() async {
        let vm = LibraryViewModel()
        vm.entries = [
            TestData.makeLibraryEntry(id: "1", title: "Getting Started", category: "getting_started"),
            TestData.makeLibraryEntry(id: "2", title: "Getting Features", category: "features"),
            TestData.makeLibraryEntry(id: "3", title: "Tips Guide", category: "getting_started"),
        ]
        vm.selectedCategory = "getting_started"
        vm.searchText = "getting"
        vm.filterEntries()

        #expect(vm.filteredEntries.count == 1)
        #expect(vm.filteredEntries.first?.id == "1")
    }

    // MARK: - Reset Category

    @Test("resetCategory sets selectedCategory to nil")
    func resetCategoryWorks() async {
        let vm = LibraryViewModel()
        vm.selectedCategory = "features"
        vm.resetCategory()

        #expect(vm.selectedCategory == nil)
    }

    // MARK: - Entry New Check

    @Test("isEntryNew returns true for entries within 30 days")
    func isEntryNewCheck() async {
        let vm = LibraryViewModel()

        #expect(vm.isEntryNew(Date()) == true)
        #expect(vm.isEntryNew(TestData.daysAgo(29)) == true)
        #expect(vm.isEntryNew(TestData.daysAgo(31)) == false)
    }

    // MARK: - Available Categories

    @Test("updateAvailableCategories extracts unique sorted categories")
    func updateCategories() async {
        let vm = LibraryViewModel()
        vm.entries = [
            TestData.makeLibraryEntry(id: "1", category: "features"),
            TestData.makeLibraryEntry(id: "2", category: "getting_started"),
            TestData.makeLibraryEntry(id: "3", category: "features"),
        ]
        vm.updateAvailableCategories()

        #expect(vm.availableCategories.count == 2)
        #expect(vm.availableCategories.contains("features"))
        #expect(vm.availableCategories.contains("getting_started"))
    }

    // MARK: - Featured Entries

    @Test("hasFeaturedEntries reflects featured status in filtered entries")
    func hasFeaturedCheck() async {
        let vm = LibraryViewModel()
        vm.entries = [
            TestData.makeLibraryEntry(id: "1", featured: true),
            TestData.makeLibraryEntry(id: "2", featured: false),
        ]
        vm.filterEntries()

        #expect(vm.hasFeaturedEntries == true)
    }

    @Test("hasFeaturedEntries returns false when no featured entries")
    func noFeaturedEntries() async {
        let vm = LibraryViewModel()
        vm.entries = [
            TestData.makeLibraryEntry(id: "1", featured: false),
            TestData.makeLibraryEntry(id: "2", featured: false),
        ]
        vm.filterEntries()

        #expect(vm.hasFeaturedEntries == false)
    }

    // MARK: - Display Name

    @Test("displayNameForCategory returns formatted name")
    func displayNameForCategory() async {
        let vm = LibraryViewModel()
        #expect(vm.displayNameForCategory("getting_started") == "Getting Started")
        #expect(vm.displayNameForCategory("features") == "Features")
    }

    // MARK: - Search with Multiple Terms

    @Test("filterEntries matches all search terms")
    func multiTermSearch() async {
        let vm = LibraryViewModel()
        vm.entries = [
            TestData.makeLibraryEntry(id: "1", title: "Getting Started Guide"),
            TestData.makeLibraryEntry(id: "2", title: "Started Features"),
            TestData.makeLibraryEntry(id: "3", title: "Getting Help"),
        ]
        vm.searchText = "getting started"
        vm.filterEntries()

        #expect(vm.filteredEntries.count == 1)
        #expect(vm.filteredEntries.first?.id == "1")
    }
}
