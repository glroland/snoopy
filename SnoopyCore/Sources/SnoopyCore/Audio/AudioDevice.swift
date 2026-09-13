import Foundation

public struct AudioDevice: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public protocol AudioDeviceProviding: Sendable {
    func inputDevices() -> [AudioDevice]
    func outputDevices() -> [AudioDevice]
}
