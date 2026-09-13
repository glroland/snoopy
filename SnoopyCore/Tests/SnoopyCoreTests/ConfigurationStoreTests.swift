import XCTest
@testable import SnoopyCore

@MainActor
final class ConfigurationStoreTests: XCTestCase {
    // Given the application loading, when no local configuration database
    // exists, then default values must be used.
    func testLoadWithNoStoredValuesUsesDefaults() {
        let store = ConfigurationStore(persistence: InMemoryConfigurationPersistence())
        let warnings = store.load()

        XCTAssertTrue(warnings.isEmpty)
        for definition in ConfigurationCatalog.standard {
            XCTAssertEqual(store.value(for: definition.id), definition.defaultValue)
        }
    }

    // Given the application loading, when a local configuration database
    // does exist, then the overridden values must be loaded and applied to
    // the in-memory values.
    func testLoadWithStoredValuesAppliesOverrides() {
        let persistence = InMemoryConfigurationPersistence(initial: [
            ConfigurationCatalog.openAIBaseURL.id: "https://override.example.com/v1",
            ConfigurationCatalog.openAITimeoutSeconds.id: "45"
        ])
        let store = ConfigurationStore(persistence: persistence)
        store.load()

        XCTAssertEqual(store.value(for: ConfigurationCatalog.openAIBaseURL.id), "https://override.example.com/v1")
        XCTAssertEqual(store.value(for: ConfigurationCatalog.openAITimeoutSeconds.id), "45")
        // Untouched keys keep their defaults.
        XCTAssertEqual(store.value(for: ConfigurationCatalog.microphone.id), ConfigurationCatalog.microphone.defaultValue)
    }

    // Given the application loading, when the local configuration database
    // exists but a value is corrupted or incompatible, then the default
    // value must be used and a warning surfaced naming the affected key.
    func testLoadWithCorruptedValueFallsBackToDefaultAndWarns() {
        let persistence = InMemoryConfigurationPersistence(initial: [
            ConfigurationCatalog.openAITimeoutSeconds.id: "not-a-number"
        ])
        let store = ConfigurationStore(persistence: persistence)
        let warnings = store.load()

        XCTAssertEqual(store.value(for: ConfigurationCatalog.openAITimeoutSeconds.id), ConfigurationCatalog.openAITimeoutSeconds.defaultValue)
        XCTAssertEqual(warnings.count, 1)
        XCTAssertEqual(warnings.first?.keyID, ConfigurationCatalog.openAITimeoutSeconds.id)
        XCTAssertTrue(warnings.first?.message.contains(ConfigurationCatalog.openAITimeoutSeconds.displayName) ?? false)
    }

    // Given a configuration key, when the key's value is being updated,
    // then the new value must be validated before modifying the old value.
    func testUpdateRejectsInvalidValueAndLeavesPreviousValueUnchanged() {
        let store = ConfigurationStore(persistence: InMemoryConfigurationPersistence())
        let originalValue = store.value(for: ConfigurationCatalog.openAITimeoutSeconds.id)

        XCTAssertThrowsError(try store.update(keyID: ConfigurationCatalog.openAITimeoutSeconds.id, rawValue: "abc")) { error in
            guard case ConfigurationError.invalidValue(let keyID, let underlying) = error else {
                return XCTFail("Expected invalidValue, got \(error)")
            }
            XCTAssertEqual(keyID, ConfigurationCatalog.openAITimeoutSeconds.id)
            XCTAssertEqual(underlying, .invalidNumber)
        }
        XCTAssertEqual(store.value(for: ConfigurationCatalog.openAITimeoutSeconds.id), originalValue)
    }

    func testUpdateAppliesValidValueAndPersistsIt() throws {
        let persistence = InMemoryConfigurationPersistence()
        let store = ConfigurationStore(persistence: persistence)

        try store.update(keyID: ConfigurationCatalog.openAITimeoutSeconds.id, rawValue: "60")

        XCTAssertEqual(store.value(for: ConfigurationCatalog.openAITimeoutSeconds.id), "60")
        XCTAssertEqual(persistence.storedRawValue(for: ConfigurationCatalog.openAITimeoutSeconds.id), "60")
    }

    // Given view settings, when the user selects "Reset to Defaults", then
    // the local configuration database is deleted and defaults restored.
    func testResetToDefaultsClearsOverridesAndWarnings() throws {
        let persistence = InMemoryConfigurationPersistence()
        let store = ConfigurationStore(persistence: persistence)
        try store.update(keyID: ConfigurationCatalog.openAITimeoutSeconds.id, rawValue: "60")

        store.resetToDefaults()

        XCTAssertEqual(store.value(for: ConfigurationCatalog.openAITimeoutSeconds.id), ConfigurationCatalog.openAITimeoutSeconds.defaultValue)
        XCTAssertNil(persistence.storedRawValue(for: ConfigurationCatalog.openAITimeoutSeconds.id))
        XCTAssertTrue(store.warnings.isEmpty)
    }
}
