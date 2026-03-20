//
//  LibraryViewModel.swift
//  MyApp
//
//  ViewModel for fetching and filtering library content.
//

import Foundation
import SwiftUI

@Observable @MainActor
final class LibraryViewModel: LibraryServiceProtocol {

    var entries: [LibraryEntry] = []
    var filteredEntries: [LibraryEntry] = []
    var selectedCategory: String? {
        didSet { filterEntries() }
    }
    var availableCategories: [String] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var lastUpdated: Date?
    var searchText: String = ""

    /// Check if there are featured entries in current filter
    var hasFeaturedEntries: Bool {
        filteredEntries.contains { $0.featured == true }
    }

    @ObservationIgnored private let cacheManager = LibraryCacheManager.shared

    @ObservationIgnored private let indexURL = AppConfiguration.libraryIndexURL

    /// URLSession configured with certificate pinning for GitHub content fetching.
    @ObservationIgnored private let pinnedSession: URLSession = {
        let delegate = GitHubContentSessionDelegate()
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
    }()

    init() {
        // Search debounce is handled in the View layer via .task(id: searchText)
        // Category changes trigger filterEntries() via didSet
    }

    // MARK: - Fetching

    func fetchEntries(forceRefresh: Bool = false) {
        Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            // Check cache first if not forcing refresh
            if !forceRefresh,
               let cachedIndex = cacheManager.getCachedIndex(),
               let cachedDate = cacheManager.getIndexLastUpdated(),
               Calendar.current.isDateInToday(cachedDate) {

                processEntries(from: cachedIndex)
                lastUpdated = cachedDate
                return
            }

            // Fetch from GitHub
            guard let url = URL(string: indexURL) else {
                errorMessage = "Invalid index URL"
                return
            }

            do {
                let (data, _) = try await pinnedSession.data(from: url)
                let libraryIndex = try JSONDecoder.libraryDecoder.decode(LibraryIndex.self, from: data)
                cacheManager.cacheIndex(libraryIndex)
                processEntries(from: libraryIndex)
                lastUpdated = libraryIndex.lastUpdated
            } catch {
                errorMessage = "Failed to fetch library: \(error.localizedDescription)"
            }
        }
    }

    private func processEntries(from index: LibraryIndex) {
        let now = Date()
        let sortedEntries = index.articles
            .filter { article in
                let isPublished = article.publishDate <= now
                let isNotExpired = article.expiryDate.map { $0 >= now } ?? true
                return isPublished && isNotExpired
            }
            .sorted(by: { $0.publishDate > $1.publishDate })

        entries = sortedEntries
        updateAvailableCategories()
        filterEntries()
    }

    // MARK: - Filtering

    func filterEntries() {
        var filtered = entries

        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }

        // Filter by search text
        if !searchText.isEmpty {
            let searchTerms = searchText.lowercased().split(separator: " ").map(String.init)
            filtered = filtered.filter { entry in
                let title = entry.title.lowercased()
                let summary = entry.summary.lowercased()
                return searchTerms.allSatisfy { term in
                    title.contains(term) || summary.contains(term)
                }
            }
        }

        filteredEntries = filtered
    }

    func updateAvailableCategories() {
        let categorySet = Set(entries.map { $0.category })
        let sortedCategories = categorySet.sorted {
            formatCategoryName($0) < formatCategoryName($1)
        }
        availableCategories = sortedCategories
    }

    func resetCategory() {
        selectedCategory = nil
    }

    func displayNameForCategory(_ category: String) -> String {
        formatCategoryName(category)
    }

    // MARK: - Content Fetching

    func fetchEntryContent(for entry: LibraryEntry) async throws -> String {
        let versionKey = entry.version

        // Check cache first
        if let cachedContent = cacheManager.getCachedContent(for: entry.id, version: versionKey) {
            return cachedContent
        }

        // Fetch from GitHub
        guard let url = URL(string: entry.contentURL) else {
            throw NSError(
                domain: "",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid content URL"]
            )
        }

        let (data, _) = try await pinnedSession.data(from: url)
        guard let content = String(data: data, encoding: .utf8) else {
            throw NSError(
                domain: "",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid content encoding"]
            )
        }
        cacheManager.cacheContent(content, for: entry.id, version: versionKey)
        return content
    }

    // MARK: - Helpers

    /// Check if an entry is new (published within last 30 days)
    func isEntryNew(_ publishDate: Date) -> Bool {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return publishDate > thirtyDaysAgo
    }
}
