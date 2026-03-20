//
//  LibraryCacheManager.swift
//  MyApp
//
//  Manages caching of library content for offline access.
//

import Foundation

class LibraryCacheManager {

    static let shared = LibraryCacheManager()

    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Index Caching

    func cacheIndex(_ index: LibraryIndex) {
        guard let data = try? JSONEncoder().encode(index) else { return }
        defaults.set(data, forKey: StorageKeys.libraryIndex)
        defaults.set(Date(), forKey: StorageKeys.libraryIndexLastUpdated)
    }

    func getCachedIndex() -> LibraryIndex? {
        guard let data = defaults.data(forKey: StorageKeys.libraryIndex),
              let index = try? JSONDecoder.libraryDecoder.decode(LibraryIndex.self, from: data) else {
            return nil
        }
        return index
    }

    func getIndexLastUpdated() -> Date? {
        defaults.object(forKey: StorageKeys.libraryIndexLastUpdated) as? Date
    }

    // MARK: - Content Caching

    func cacheContent(_ content: String, for entryId: String, version: Int) {
        let key = StorageKeys.libraryContent(id: entryId, version: version)
        defaults.set(content, forKey: key)
    }

    func getCachedContent(for entryId: String, version: Int) -> String? {
        let key = StorageKeys.libraryContent(id: entryId, version: version)
        return defaults.string(forKey: key)
    }

    // MARK: - Cache Management

    func clearCache() {
        defaults.removeObject(forKey: StorageKeys.libraryIndex)
        defaults.removeObject(forKey: StorageKeys.libraryIndexLastUpdated)

        // Remove all content cache
        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix(StorageKeys.libraryContentCachePrefix) {
            defaults.removeObject(forKey: key)
        }
    }

    /// Get approximate cache size in bytes
    var approximateCacheSize: Int {
        var size = 0

        if let indexData = defaults.data(forKey: StorageKeys.libraryIndex) {
            size += indexData.count
        }

        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix(StorageKeys.libraryContentCachePrefix) {
            if let content = defaults.string(forKey: key) {
                size += content.utf8.count
            }
        }

        return size
    }
}
