import Testing
import Foundation
@testable import MyApp

@Suite("KeychainHelper Tests")
struct KeychainHelperTests {

    private let helper = KeychainHelper.shared

    /// Generate a unique key per test to avoid cross-test contamination
    private func uniqueKey(_ suffix: String = #function) -> String {
        "test_keychain_\(suffix)_\(UUID().uuidString.prefix(8))"
    }

    // MARK: - Save and Read Roundtrip

    @Test("Save and read string roundtrip returns same value")
    func saveAndReadStringRoundtrip() throws {
        let key = uniqueKey()
        defer { helper.delete(forKey: key) }

        try helper.save("hello-world", forKey: key)
        let result = helper.readString(forKey: key)

        #expect(result == "hello-world")
    }

    @Test("Save and read Data roundtrip returns same bytes")
    func saveAndReadDataRoundtrip() throws {
        let key = uniqueKey()
        defer { helper.delete(forKey: key) }

        let data = Data([0x01, 0x02, 0x03, 0xFF])
        try helper.save(data, forKey: key)
        let result = helper.read(forKey: key)

        #expect(result == data)
    }

    // MARK: - Non-Existent Key

    @Test("Read returns nil for non-existent key")
    func readNonExistentKeyReturnsNil() {
        let key = uniqueKey()
        let result = helper.readString(forKey: key)

        #expect(result == nil)
    }

    @Test("Read Data returns nil for non-existent key")
    func readDataNonExistentKeyReturnsNil() {
        let key = uniqueKey()
        let result = helper.read(forKey: key)

        #expect(result == nil)
    }

    // MARK: - Delete

    @Test("Delete removes item so read returns nil")
    func deleteRemovesItem() throws {
        let key = uniqueKey()

        try helper.save("to-be-deleted", forKey: key)
        #expect(helper.readString(forKey: key) == "to-be-deleted")

        helper.delete(forKey: key)
        #expect(helper.readString(forKey: key) == nil)
    }

    @Test("Delete on non-existent key does not throw")
    func deleteNonExistentKeyIsNoOp() {
        let key = uniqueKey()
        // Should not crash or throw
        helper.delete(forKey: key)
    }

    // MARK: - Overwrite

    @Test("Save overwrites existing value")
    func saveOverwritesExistingValue() throws {
        let key = uniqueKey()
        defer { helper.delete(forKey: key) }

        try helper.save("original", forKey: key)
        #expect(helper.readString(forKey: key) == "original")

        try helper.save("updated", forKey: key)
        #expect(helper.readString(forKey: key) == "updated")
    }

    // MARK: - Migration from UserDefaults

    @Test("migrateFromUserDefaults moves value and cleans UserDefaults")
    func migrateFromUserDefaultsMovesValue() {
        let key = uniqueKey()
        defer {
            helper.delete(forKey: key)
            UserDefaults.standard.removeObject(forKey: key)
        }

        // Plant a value in UserDefaults
        UserDefaults.standard.set("migrated-secret", forKey: key)
        #expect(UserDefaults.standard.string(forKey: key) == "migrated-secret")

        // Migrate
        helper.migrateFromUserDefaults(key: key)

        // Value should now be in Keychain
        #expect(helper.readString(forKey: key) == "migrated-secret")

        // Value should be removed from UserDefaults
        #expect(UserDefaults.standard.string(forKey: key) == nil)
    }

    @Test("migrateFromUserDefaults is no-op when key not in UserDefaults")
    func migrateNoOpWhenKeyMissing() {
        let key = uniqueKey()
        defer { helper.delete(forKey: key) }

        // No value in UserDefaults -- migration should be a no-op
        helper.migrateFromUserDefaults(key: key)

        // Keychain should still have nothing
        #expect(helper.readString(forKey: key) == nil)
    }
}
