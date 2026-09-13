import Foundation

public struct ConfigurationLoadWarning: Equatable, Sendable {
    public let keyID: String
    public let displayName: String
    public let message: String

    public init(keyID: String, displayName: String, message: String) {
        self.keyID = keyID
        self.displayName = displayName
        self.message = message
    }
}

public enum ConfigurationError: Error, Equatable, Sendable {
    case unknownKey(String)
    case invalidValue(keyID: String, underlying: ConfigurationValidationError)
}

/// The in-memory, always-available configuration for the app, backed by a
/// persisted set of overrides. See spec/030-configurable-values.md.
@MainActor
public final class ConfigurationStore: ObservableObject {
    public let catalog: [ConfigurationKeyDefinition]
    private let persistence: ConfigurationPersisting

    @Published public private(set) var values: [String: String]
    @Published public private(set) var warnings: [ConfigurationLoadWarning] = []

    public init(
        catalog: [ConfigurationKeyDefinition] = ConfigurationCatalog.standard,
        persistence: ConfigurationPersisting = UserDefaultsConfigurationPersistence()
    ) {
        self.catalog = catalog
        self.persistence = persistence
        self.values = Dictionary(uniqueKeysWithValues: catalog.map { ($0.id, $0.defaultValue) })
    }

    public func definition(for keyID: String) -> ConfigurationKeyDefinition? {
        catalog.first { $0.id == keyID }
    }

    public func value(for keyID: String) -> String {
        values[keyID] ?? definition(for: keyID)?.defaultValue ?? ""
    }

    /// Loads persisted overrides, validating each one. A stored value that
    /// fails validation is dropped in favor of the key's default, and is
    /// reported back as a warning for the caller to surface (e.g. as an
    /// acknowledgeable dialog).
    @discardableResult
    public func load() -> [ConfigurationLoadWarning] {
        var resolved = Dictionary(uniqueKeysWithValues: catalog.map { ($0.id, $0.defaultValue) })
        var newWarnings: [ConfigurationLoadWarning] = []

        for definition in catalog {
            guard let stored = persistence.storedRawValue(for: definition.id) else { continue }
            switch ConfigurationValidator.validate(stored, as: definition.type) {
            case .success:
                resolved[definition.id] = stored
            case .failure:
                newWarnings.append(ConfigurationLoadWarning(
                    keyID: definition.id,
                    displayName: definition.displayName,
                    message: "The saved value for \"\(definition.displayName)\" could not be loaded and its default was used instead."
                ))
            }
        }

        values = resolved
        warnings = newWarnings
        return newWarnings
    }

    /// Validates `rawValue` before applying it. On failure the previous
    /// value is left untouched and an error is thrown for the caller to
    /// surface to the user.
    public func update(keyID: String, rawValue: String) throws {
        guard let definition = definition(for: keyID) else {
            throw ConfigurationError.unknownKey(keyID)
        }
        switch ConfigurationValidator.validate(rawValue, as: definition.type) {
        case .failure(let error):
            throw ConfigurationError.invalidValue(keyID: keyID, underlying: error)
        case .success:
            values[keyID] = rawValue
            persistence.setStoredRawValue(rawValue, for: keyID)
        }
    }

    public func resetToDefaults() {
        persistence.removeAll(keyIDs: catalog.map(\.id))
        values = Dictionary(uniqueKeysWithValues: catalog.map { ($0.id, $0.defaultValue) })
        warnings = []
    }
}
