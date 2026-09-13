import XCTest
@testable import SnoopyCore

@MainActor
final class ConversationEngineTests: XCTestCase {
    private func makeEngine(chatService: FakeChatCompletionsService) -> ConversationEngine {
        let store = ConfigurationStore(persistence: InMemoryConfigurationPersistence())
        return ConversationEngine(persona: .default, chatService: chatService, configuration: store)
    }

    // Given the main interaction page, when a user inquiry is received,
    // then an LLM inference should be made.
    func testUserInquiryTriggersInference() async throws {
        let chatService = FakeChatCompletionsService()
        let engine = makeEngine(chatService: chatService)

        _ = try await engine.respond(to: "What's the weather?", history: [])

        XCTAssertEqual(chatService.callCount, 1)
    }

    // Given the main interaction page, when an LLM inference is made, then
    // the system prompt must be included in the conversation.
    func testInferenceIncludesSystemPrompt() async throws {
        let chatService = FakeChatCompletionsService()
        let engine = makeEngine(chatService: chatService)

        _ = try await engine.respond(to: "Hello", history: [])

        XCTAssertEqual(chatService.lastMessages?.first?.role, .system)
        XCTAssertEqual(chatService.lastMessages?.first?.content, Persona.default.systemPrompt)
    }

    func testMessageBuilderOrdersHistoryChronologicallyBeforeNewInput() {
        let older = TranscriptEntry(speaker: .user, text: "first", timestamp: Date(timeIntervalSince1970: 0))
        let newer = TranscriptEntry(speaker: .assistant, text: "second", timestamp: Date(timeIntervalSince1970: 10))

        let messages = ConversationMessageBuilder.buildMessages(persona: .default, history: [newer, older], userInput: "third")

        XCTAssertEqual(messages.map(\.content), [Persona.default.systemPrompt, "first", "second", "third"])
        XCTAssertEqual(messages.map(\.role), [.system, .user, .assistant, .user])
    }
}
