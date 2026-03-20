import Foundation
@testable import MyApp

@MainActor
final class MockLibraryService: LibraryServiceProtocol {

    // MARK: - Configurable State

    var entries: [LibraryEntry] = []
    var filteredEntries: [LibraryEntry] = []
    var selectedCategory: String? = nil
    var availableCategories: [String] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var lastUpdated: Date? = nil
    var searchText: String = ""
    var hasFeaturedEntries: Bool = false

    // MARK: - Configurable Behavior

    var fetchEntriesResult: Result<[LibraryEntry], Error> = .success([])
    var fetchContentResult: Result<String, Error> = .success("# Test Content")

    // MARK: - Call Tracking

    var fetchEntriesCallCount = 0
    var fetchEntriesLastForceRefresh: Bool?
    var fetchEntryContentCallCount = 0
    var filterEntriesCallCount = 0
    var updateAvailableCategoriesCallCount = 0
    var resetCategoryCallCount = 0
    var displayNameForCategoryCallCount = 0
    var isEntryNewCallCount = 0

    // MARK: - Protocol Conformance

    func fetchEntries(forceRefresh: Bool) {
        fetchEntriesCallCount += 1
        fetchEntriesLastForceRefresh = forceRefresh
        switch fetchEntriesResult {
        case .success(let items):
            entries = items
            filteredEntries = items
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    func fetchEntryContent(for entry: LibraryEntry) async throws -> String {
        fetchEntryContentCallCount += 1
        switch fetchContentResult {
        case .success(let content):
            return content
        case .failure(let error):
            throw error
        }
    }

    func filterEntries() {
        filterEntriesCallCount += 1
    }

    func updateAvailableCategories() {
        updateAvailableCategoriesCallCount += 1
    }

    func resetCategory() {
        resetCategoryCallCount += 1
        selectedCategory = nil
    }

    func displayNameForCategory(_ category: String) -> String {
        displayNameForCategoryCallCount += 1
        return category
    }

    func isEntryNew(_ publishDate: Date) -> Bool {
        isEntryNewCallCount += 1
        return true
    }
}
