//
//  LibraryCacheManagerTests.swift
//  MyAppTests
//
//  Tests for LibraryCacheManager caching and retrieval of library content.
//

import Testing
import Foundation
@testable import MyApp

@Suite("LibraryCacheManager Tests")
struct LibraryCacheManagerTests {

    /// Unique test entry IDs to avoid collisions with other tests
    private let testEntryId = "cache-test-entry-\(UUID().uuidString.prefix(8))"

    // MARK: - Index Cache

    @Test("cacheIndex and getCachedIndex roundtrip")
    func indexCacheRoundtrip() {
        let manager = LibraryCacheManager.shared

        let entry = TestData.makeLibraryEntry(id: "cached-article-1", title: "Cached Article")
        let index = LibraryIndex(
            lastUpdated: Date(),
            articles: [entry],
            version: "1.0"
        )

        manager.cacheIndex(index)

        let cached = manager.getCachedIndex()
        #expect(cached != nil, "Expected cached index to be retrievable")
        #expect(cached?.articles.count == 1)
        #expect(cached?.articles.first?.id == "cached-article-1")
        #expect(cached?.articles.first?.title == "Cached Article")
        #expect(cached?.version == "1.0")

        // Verify last updated date was also stored
        let lastUpdated = manager.getIndexLastUpdated()
        #expect(lastUpdated != nil, "Expected index last-updated date to be stored")

        // Cleanup
        manager.clearCache()
    }

    // MARK: - Content Cache

    @Test("getCachedContent returns nil for missing content")
    func missingContentReturnsNil() {
        let manager = LibraryCacheManager.shared

        let result = manager.getCachedContent(for: "nonexistent-entry-id-xyz", version: 999)
        #expect(result == nil, "Expected nil for content that was never cached")
    }

    @Test("cacheContent and getCachedContent roundtrip")
    func contentCacheRoundtrip() {
        let manager = LibraryCacheManager.shared
        let entryId = testEntryId
        let version = 42
        let markdownContent = """
        # Test Article

        This is some **markdown** content for testing the cache.

        - Item 1
        - Item 2
        """

        manager.cacheContent(markdownContent, for: entryId, version: version)

        let cached = manager.getCachedContent(for: entryId, version: version)
        #expect(cached != nil, "Expected cached content to be retrievable")
        #expect(cached == markdownContent, "Cached content should match original content exactly")

        // Different version should return nil
        let differentVersion = manager.getCachedContent(for: entryId, version: version + 1)
        #expect(differentVersion == nil, "Expected nil for a different version of the same entry")

        // Cleanup: clear cache removes all entries
        manager.clearCache()
        let afterClear = manager.getCachedContent(for: entryId, version: version)
        #expect(afterClear == nil, "Expected nil after clearing cache")
    }
}
