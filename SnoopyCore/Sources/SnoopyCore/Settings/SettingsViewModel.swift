import Foundation

/// One row in the settings view.
public struct SettingsItem: Identifiable, Equatable, Sendable {
    public let definition: ConfigurationKeyDefinition
    public let value: String
    public let warning: String?

    public var id: String { definition.id }

    public init(definition: ConfigurationKeyDefinition, value: String, warning: String?) {
        self.definition = definition
        self.value = value
        self.warning = warning
    }
}

public enum SettingsViewState: Equatable, Sendable {
    case notLoaded
    case loaded([SettingsItem])
    case fatalError(String)
}

/// Backs the settings screen in spec/040-settings-management.md: only
/// user-managed keys are shown, values can be viewed/changed/reset, device
/// keys get a device picker, and URL keys get a reachability test.
@MainActor
public final class SettingsViewModel: ObservableObject {
    @Published public private(set) var state: SettingsViewState

    /// Optional so the "in-memory configuration does not exist" acceptance
    /// criterion in spec/040-settings-management.md is representable and
    /// testable, even though in practice the store is always constructed
    /// before the settings view is shown.
    private let configuration: ConfigurationStore?
    private let deviceProvider: AudioDeviceProviding
    private let connectivityTester: URLConnectivityTesting

    public init(
        configuration: ConfigurationStore?,
        deviceProvider: AudioDeviceProviding = SystemAudioDeviceProvider(),
        connectivityTester: URLConnectivityTesting = HTTPURLConnectivityTester()
    ) {
        self.configuration = configuration
        self.deviceProvider = deviceProvider
        self.connectivityTester = connectivityTester
        self.state = configuration == nil ? .fatalError("No configuration is available.") : .notLoaded
    }

    public func load() {
        guard let configuration else { return }
        let warnings = configuration.load()
        refresh(warnings: warnings)
    }

    public func refresh(warnings: [ConfigurationLoadWarning] = []) {
        guard let configuration else { return }
        let warningsByKey = Dictionary(uniqueKeysWithValues: warnings.map { ($0.keyID, $0.message) })
        let items = configuration.catalog
            .filter(\.isUserManaged)
            .map { definition in
                SettingsItem(
                    definition: definition,
                    value: configuration.value(for: definition.id),
                    warning: warningsByKey[definition.id]
                )
            }
        state = .loaded(items)
    }

    public func update(keyID: String, rawValue: String) -> String? {
        guard let configuration else { return "No configuration is available." }
        do {
            try configuration.update(keyID: keyID, rawValue: rawValue)
            refresh()
            return nil
        } catch ConfigurationError.invalidValue(_, let underlying) {
            return "That value isn't valid: \(underlying)"
        } catch {
            return "That value couldn't be saved."
        }
    }

    public func resetToDefaults() {
        guard let configuration else { return }
        configuration.resetToDefaults()
        refresh()
    }

    public func devices(for keyID: String) -> [AudioDevice] {
        if keyID == ConfigurationCatalog.microphone.id {
            return deviceProvider.inputDevices()
        }
        if keyID == ConfigurationCatalog.speaker.id {
            return deviceProvider.outputDevices()
        }
        return []
    }

    public func testConnection(for keyID: String) async -> URLConnectivityResult {
        guard let configuration else {
            return URLConnectivityResult(succeeded: false, message: "No configuration is available.")
        }
        guard let url = URL(string: configuration.value(for: keyID)) else {
            return URLConnectivityResult(succeeded: false, message: "That URL isn't valid.")
        }
        let apiKey = configuration.value(for: ConfigurationCatalog.openAIAPIKey.id)
        return await connectivityTester.testConnection(to: url, apiKey: apiKey)
    }
}
