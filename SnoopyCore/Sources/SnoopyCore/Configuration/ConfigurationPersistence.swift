import Foundation

/// Storage for the raw (unvalidated) override values a user has saved for
/// each configuration key. This is the "local configuration database"
/// referenced in spec/030-configurable-values.md.
public protocol ConfigurationPersisting: Sendable {
    func storedRawValue(for keyID: String) -> String?
    func setStoredRawValue(_ value: String, for keyID: String)
    func removeAll(keyIDs: [String])
}

public final class UserDefaultsConfigurationPersistence: ConfigurationPersisting, @unchecked Sendable {
    private let defaults: UserDefaults
    private let keyPrefix: String

    public init(defaults: UserDefaults = .standard, keyPrefix: String = "com.glroland.SnoopyAI.config.") {
        self.defaults = defaults
        self.keyPrefix = keyPrefix
    }

    public func storedRawValue(for keyID: String) -> String? {
        defaults.string(forKey: keyPrefix + keyID)
    }

    public func setStoredRawValue(_ value: String, for keyID: String) {
        defaults.set(value, forKey: keyPrefix + keyID)
    }

    public func removeAll(keyIDs: [String]) {
        for keyID in keyIDs {
            defaults.removeObject(forKey: keyPrefix + keyID)
        }
    }
}

public final class InMemoryConfigurationPersistence: ConfigurationPersisting, @unchecked Sendable {
    private var storage: [String: String]

    public init(initial: [String: String] = [:]) {
        self.storage = initial
    }

    public func storedRawValue(for keyID: String) -> String? {
        storage[keyID]
    }

    public func setStoredRawValue(_ value: String, for keyID: String) {
        storage[keyID] = value
    }

    public func removeAll(keyIDs: [String]) {
        for keyID in keyIDs {
            storage.removeValue(forKey: keyID)
        }
    }
}
