import Foundation

public enum ConfigurationValueType: String, Sendable {
    case deviceID
    case url
    case password
    case number
}

public struct ConfigurationKeyDefinition: Identifiable, Equatable, Sendable {
    public let id: String
    public let displayName: String
    public let type: ConfigurationValueType
    public let defaultValue: String
    public let isUserManaged: Bool

    public init(id: String, displayName: String, type: ConfigurationValueType, defaultValue: String, isUserManaged: Bool) {
        self.id = id
        self.displayName = displayName
        self.type = type
        self.defaultValue = defaultValue
        self.isUserManaged = isUserManaged
    }
}
