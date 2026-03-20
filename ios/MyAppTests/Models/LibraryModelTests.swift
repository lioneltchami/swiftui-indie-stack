import Testing
import SwiftUI
@testable import MyApp

@Suite("LibraryModel Tests")
struct LibraryModelTests {

    // MARK: - Category Name Formatting

    @Test("formatCategoryName converts snake_case to title case")
    func categoryNameFormatting() {
        #expect(formatCategoryName("getting_started") == "Getting Started")
        #expect(formatCategoryName("tips") == "Tips")
        #expect(formatCategoryName("advanced_features") == "Advanced Features")
    }

    @Test("formatCategoryName handles single word")
    func singleWordCategory() {
        #expect(formatCategoryName("features") == "Features")
        #expect(formatCategoryName("support") == "Support")
    }

    @Test("formatCategoryName handles multiple underscores")
    func multipleUnderscoreCategory() {
        #expect(formatCategoryName("my_long_category_name") == "My Long Category Name")
    }

    // MARK: - LibraryEntry Equality

    @Test("LibraryEntry equality based on id and version")
    func entryEquality() {
        let entry1 = TestData.makeLibraryEntry(id: "a")
        let entry2 = TestData.makeLibraryEntry(id: "a")
        let entry3 = TestData.makeLibraryEntry(id: "b")

        #expect(entry1 == entry2)
        #expect(entry1 != entry3)
    }

    @Test("LibraryEntry with same id but different title is still equal")
    func entryEqualityIgnoresTitle() {
        let entry1 = TestData.makeLibraryEntry(id: "same-id", title: "Title A")
        let entry2 = TestData.makeLibraryEntry(id: "same-id", title: "Title B")

        #expect(entry1 == entry2)
    }

    // MARK: - Category Colors

    @Test("categoryColor returns consistent known colors")
    func categoryColors() {
        #expect("getting_started".categoryColor == .blue)
        #expect("features".categoryColor == .purple)
        #expect("tips".categoryColor == .green)
        #expect("support".categoryColor == .orange)
        #expect("about".categoryColor == .cyan)
    }

    @Test("categoryColor returns a color for unknown categories")
    func unknownCategoryColor() {
        // Should not crash, should return some color
        let color = "unknown_category".categoryColor
        #expect(color != nil as Color?)
    }

    // MARK: - Category Icons

    @Test("categoryIcon returns correct icons for known categories")
    func categoryIcons() {
        #expect("getting_started".categoryIcon == "book.pages")
        #expect("features".categoryIcon == "gear")
        #expect("tips".categoryIcon == "lightbulb")
        #expect("support".categoryIcon == "questionmark.circle")
        #expect("about".categoryIcon == "info.circle")
    }

    @Test("categoryIcon returns default for unknown categories")
    func unknownCategoryIcon() {
        #expect("something_else".categoryIcon == "doc.text")
    }

    // MARK: - JSON Decoder

    @Test("JSONDecoder.libraryDecoder handles ISO 8601 dates")
    func decoderDateHandling() throws {
        let json = """
        {
            "lastUpdated": "2024-01-15T10:00:00Z",
            "version": "1.0",
            "articles": []
        }
        """.data(using: .utf8)!

        let index = try JSONDecoder.libraryDecoder.decode(LibraryIndex.self, from: json)
        #expect(index.articles.isEmpty)
        #expect(index.version == "1.0")
    }

    @Test("JSONDecoder.libraryDecoder decodes full article entry")
    func decoderFullEntry() throws {
        let json = """
        {
            "lastUpdated": "2024-06-01T00:00:00Z",
            "version": "2.0",
            "articles": [
                {
                    "id": "test-1",
                    "title": "Test Article",
                    "summary": "A test summary",
                    "contentURL": "https://example.com/test.md",
                    "publishDate": "2024-05-15T12:00:00Z",
                    "category": "getting_started",
                    "version": "1.0"
                }
            ]
        }
        """.data(using: .utf8)!

        let index = try JSONDecoder.libraryDecoder.decode(LibraryIndex.self, from: json)
        #expect(index.articles.count == 1)
        #expect(index.articles.first?.id == "test-1")
        #expect(index.articles.first?.title == "Test Article")
        #expect(index.articles.first?.category == "getting_started")
    }
}
