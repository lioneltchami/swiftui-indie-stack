//
//  LibraryServiceProtocol.swift
//  MyApp
//
//  Protocol abstraction for LibraryViewModel.
//  Uses async/await signatures for content fetching (migrating away from Combine).
//  References local model types (LibraryEntry) with no external dependencies.
//

import Foundation

@MainActor
protocol LibraryServiceProtocol: AnyObject {

    // MARK: - Observable State

    /// All library entries (unfiltered)
    var entries: [LibraryEntry] { get }

    /// Filtered library entries based on search text and selected category
    var filteredEntries: [LibraryEntry] { get }

    /// Currently selected category filter (nil means all categories)
    var selectedCategory: String? { get set }

    /// Available categories extracted from entries
    var availableCategories: [String] { get }

    /// Whether entries are currently being fetched
    var isLoading: Bool { get }

    /// Error message from the most recent fetch attempt
    var errorMessage: String? { get }

    /// Timestamp of the last successful index fetch
    var lastUpdated: Date? { get }

    /// Current search text for filtering entries
    var searchText: String { get set }

    // MARK: - Computed Properties

    /// Whether the current filtered results contain any featured entries
    var hasFeaturedEntries: Bool { get }

    // MARK: - Fetching

    /// Fetch library entries from remote or cache
    /// - Parameter forceRefresh: If true, bypass the cache and fetch from remote
    func fetchEntries(forceRefresh: Bool)

    /// Fetch the full content for a specific library entry
    /// - Parameter entry: The entry whose content to fetch
    /// - Returns: The content string (e.g., Markdown)
    /// - Throws: If the fetch or decoding fails
    func fetchEntryContent(for entry: LibraryEntry) async throws -> String

    // MARK: - Filtering

    /// Apply current search text and category filters to entries
    func filterEntries()

    /// Update the list of available categories from current entries
    func updateAvailableCategories()

    /// Reset the selected category filter to nil (show all)
    func resetCategory()

    /// Get a display-friendly name for a category
    /// - Parameter category: The raw category string
    /// - Returns: Formatted display name
    func displayNameForCategory(_ category: String) -> String

    // MARK: - Helpers

    /// Check if a publish date is within the last 30 days
    /// - Parameter publishDate: The date to check
    /// - Returns: `true` if the entry is considered "new"
    func isEntryNew(_ publishDate: Date) -> Bool
}
