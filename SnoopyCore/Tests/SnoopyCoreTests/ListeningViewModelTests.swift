import XCTest
@testable import SnoopyCore

@MainActor
final class ListeningViewModelTests: XCTestCase {
    private func makeViewModel(
        chatService: FakeChatCompletionsService = FakeChatCompletionsService(),
        speechRecognizer: FakeSpeechRecognizer = FakeSpeechRecognizer()
    ) -> ListeningViewModel {
        let store = ConfigurationStore(persistence: InMemoryConfigurationPersistence())
        let engine = ConversationEngine(persona: .default, chatService: chatService, configuration: store)
        return ListeningViewModel(speechRecognizer: speechRecognizer, conversationEngine: engine)
    }

    // Given the main listening view, when the page is first opened, then
    // listening should be off by default.
    func testListeningIsOffByDefault() {
        let viewModel = makeViewModel()
        XCTAssertFalse(viewModel.isListening)
    }

    func testToggleListeningFlipsState() {
        let viewModel = makeViewModel()

        viewModel.toggleListening()
        XCTAssertTrue(viewModel.isListening)

        viewModel.toggleListening()
        XCTAssertFalse(viewModel.isListening)
    }

    // Given the main listening view, when the user accesses Settings, then
    // the Settings management view must be opened.
    func testOpenSettingsShowsSettings() {
        let viewModel = makeViewModel()
        XCTAssertFalse(viewModel.isShowingSettings)

        viewModel.openSettings()

        XCTAssertTrue(viewModel.isShowingSettings)
    }

    // Given the main listening view, when the user speaks into the app
    // while it is listening, then their words must be transcribed and an
    // AI response appended, newest first.
    func testRecognizedSpeechAppendsUserThenAssistantEntriesNewestFirst() async {
        let chatService = FakeChatCompletionsService()
        chatService.responseText = "Hi there!"
        let viewModel = makeViewModel(chatService: chatService)

        await viewModel.handleRecognizedSpeech("Hello Snoopy")

        XCTAssertEqual(viewModel.transcript.entries.count, 2)
        XCTAssertEqual(viewModel.transcript.entries[0].speaker, .assistant)
        XCTAssertEqual(viewModel.transcript.entries[0].text, "Hi there!")
        XCTAssertEqual(viewModel.transcript.entries[1].speaker, .user)
        XCTAssertEqual(viewModel.transcript.entries[1].text, "Hello Snoopy")
    }

    func testFailedInferenceStillAppendsAFallbackAssistantEntry() async {
        let chatService = FakeChatCompletionsService()
        chatService.errorToThrow = LLMServiceError.badResponse
        let viewModel = makeViewModel(chatService: chatService)

        await viewModel.handleRecognizedSpeech("Hello Snoopy")

        XCTAssertEqual(viewModel.transcript.entries.count, 2)
        XCTAssertEqual(viewModel.transcript.entries[0].speaker, .assistant)
    }

    func testStartListeningInvokesSpeechRecognizer() {
        let speechRecognizer = FakeSpeechRecognizer()
        let viewModel = makeViewModel(speechRecognizer: speechRecognizer)

        viewModel.startListening()

        XCTAssertEqual(speechRecognizer.startCallCount, 1)
    }

    func testStopListeningInvokesSpeechRecognizer() {
        let speechRecognizer = FakeSpeechRecognizer()
        let viewModel = makeViewModel(speechRecognizer: speechRecognizer)

        viewModel.startListening()
        viewModel.stopListening()

        XCTAssertEqual(speechRecognizer.stopCallCount, 1)
        XCTAssertFalse(viewModel.isListening)
    }
}
