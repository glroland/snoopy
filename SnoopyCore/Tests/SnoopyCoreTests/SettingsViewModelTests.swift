import XCTest
@testable import SnoopyCore

@MainActor
final class SettingsViewModelTests: XCTestCase {
    private func makeViewModel(
        catalog: [ConfigurationKeyDefinition] = ConfigurationCatalog.standard,
        persistence: ConfigurationPersisting = InMemoryConfigurationPersistence(),
        deviceProvider: FakeAudioDeviceProvider = FakeAudioDeviceProvider(),
        connectivityTester: FakeURLConnectivityTester = FakeURLConnectivityTester()
    ) -> (SettingsViewModel, ConfigurationStore) {
        let store = ConfigurationStore(catalog: catalog, persistence: persistence)
        let viewModel = SettingsViewModel(configuration: store, deviceProvider: deviceProvider, connectivityTester: connectivityTester)
        return (viewModel, store)
    }

    // Given view settings, when in-memory configuration exists, then the
    // configuration key must be shown only if "User Managed" is yes.
    func testOnlyUserManagedKeysAreShown() {
        let catalog = [
            ConfigurationKeyDefinition(id: "visible", displayName: "Visible", type: .number, defaultValue: "1", isUserManaged: true),
            ConfigurationKeyDefinition(id: "hidden", displayName: "Hidden", type: .number, defaultValue: "2", isUserManaged: false)
        ]
        let (viewModel, _) = makeViewModel(catalog: catalog)
        viewModel.load()

        guard case .loaded(let items) = viewModel.state else { return XCTFail("Expected loaded state") }
        XCTAssertEqual(items.map(\.id), ["visible"])
    }

    // Given view settings, when a configuration key is shown, then the
    // current value must be presented in the UI.
    func testShownItemsIncludeCurrentValue() throws {
        let persistence = InMemoryConfigurationPersistence()
        let (viewModel, store) = makeViewModel(persistence: persistence)
        try store.update(keyID: ConfigurationCatalog.openAITimeoutSeconds.id, rawValue: "77")
        viewModel.load()

        guard case .loaded(let items) = viewModel.state else { return XCTFail("Expected loaded state") }
        let item = items.first { $0.id == ConfigurationCatalog.openAITimeoutSeconds.id }
        XCTAssertEqual(item?.value, "77")
    }

    // Given view settings, when in-memory configuration does not exist,
    // then a fatal error should be shown to the user.
    func testMissingConfigurationProducesFatalErrorState() {
        let viewModel = SettingsViewModel(configuration: nil)
        guard case .fatalError = viewModel.state else {
            return XCTFail("Expected fatalError state, got \(viewModel.state)")
        }
    }

    // Given view settings, when the local configuration database exists but
    // a value is corrupted, then the default is used and a warning is
    // attached to that item for inline display.
    func testCorruptedValueAttachesWarningToItem() {
        let persistence = InMemoryConfigurationPersistence(initial: [
            ConfigurationCatalog.openAITimeoutSeconds.id: "not-a-number"
        ])
        let (viewModel, _) = makeViewModel(persistence: persistence)
        viewModel.load()

        guard case .loaded(let items) = viewModel.state else { return XCTFail("Expected loaded state") }
        let item = items.first { $0.id == ConfigurationCatalog.openAITimeoutSeconds.id }
        XCTAssertEqual(item?.value, ConfigurationCatalog.openAITimeoutSeconds.defaultValue)
        XCTAssertNotNil(item?.warning)
    }

    // Given view settings, when the user selects "Reset to Defaults", then
    // the database is deleted and the view reloaded with default values.
    func testResetToDefaultsReloadsWithDefaults() throws {
        let (viewModel, store) = makeViewModel()
        try store.update(keyID: ConfigurationCatalog.openAITimeoutSeconds.id, rawValue: "77")
        viewModel.load()

        viewModel.resetToDefaults()

        guard case .loaded(let items) = viewModel.state else { return XCTFail("Expected loaded state") }
        let item = items.first { $0.id == ConfigurationCatalog.openAITimeoutSeconds.id }
        XCTAssertEqual(item?.value, ConfigurationCatalog.openAITimeoutSeconds.defaultValue)
    }

    // Given view settings, when the configuration key is Microphone, then
    // only audio input devices are shown; when Speaker, only outputs.
    func testDeviceListsAreFilteredByKey() {
        let deviceProvider = FakeAudioDeviceProvider()
        deviceProvider.inputs = [AudioDevice(id: "mic-1", name: "Built-in Mic")]
        deviceProvider.outputs = [AudioDevice(id: "spk-1", name: "Built-in Speaker")]
        let (viewModel, _) = makeViewModel(deviceProvider: deviceProvider)

        XCTAssertEqual(viewModel.devices(for: ConfigurationCatalog.microphone.id), deviceProvider.inputs)
        XCTAssertEqual(viewModel.devices(for: ConfigurationCatalog.speaker.id), deviceProvider.outputs)
    }

    // Given view settings, when the configuration key is of type URL
    // String, then a test button checks connectivity, including the API
    // key as a Bearer token when one is configured.
    func testConnectionTestIncludesAPIKeyHeader() async throws {
        let persistence = InMemoryConfigurationPersistence()
        let connectivityTester = FakeURLConnectivityTester()
        let (viewModel, store) = makeViewModel(persistence: persistence, connectivityTester: connectivityTester)
        try store.update(keyID: ConfigurationCatalog.openAIAPIKey.id, rawValue: "secret-key")

        let result = await viewModel.testConnection(for: ConfigurationCatalog.openAIBaseURL.id)

        XCTAssertTrue(result.succeeded)
        XCTAssertEqual(connectivityTester.lastAPIKey, "secret-key")
        XCTAssertEqual(connectivityTester.lastRequestedURL, URL(string: ConfigurationCatalog.openAIBaseURL.defaultValue))
    }
}
