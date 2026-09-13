import Foundation

/// Builds the OpenAI-compatible message list for an inference call: the
/// persona's system prompt first, then the conversation history in
/// chronological order, then the new user input. See
/// spec/020-ai-personna-design.md.
public enum ConversationMessageBuilder {
    public static func buildMessages(persona: Persona, history: [TranscriptEntry], userInput: String) -> [LLMMessage] {
        var messages: [LLMMessage] = [LLMMessage(role: .system, content: persona.systemPrompt)]
        for entry in history.sorted(by: { $0.timestamp < $1.timestamp }) {
            messages.append(LLMMessage(role: entry.speaker == .user ? .user : .assistant, content: entry.text))
        }
        messages.append(LLMMessage(role: .user, content: userInput))
        return messages
    }
}

/// Drives an LLM inference for a single persona, sourcing the endpoint,
/// API key, and timeout from the app's configuration.
@MainActor
public final class ConversationEngine {
    private let persona: Persona
    private let chatService: ChatCompletionsService
    private let configuration: ConfigurationStore

    public init(persona: Persona, chatService: ChatCompletionsService, configuration: ConfigurationStore) {
        self.persona = persona
        self.chatService = chatService
        self.configuration = configuration
    }

    public func respond(to userInput: String, history: [TranscriptEntry]) async throws -> String {
        let messages = ConversationMessageBuilder.buildMessages(persona: persona, history: history, userInput: userInput)
        guard let baseURL = URL(string: configuration.value(for: ConfigurationCatalog.openAIBaseURL.id)) else {
            throw LLMServiceError.badResponse
        }
        let apiKey = configuration.value(for: ConfigurationCatalog.openAIAPIKey.id)
        let timeout = Int(configuration.value(for: ConfigurationCatalog.openAITimeoutSeconds.id)) ?? 30
        return try await chatService.complete(messages: messages, baseURL: baseURL, apiKey: apiKey, timeoutSeconds: timeout)
    }
}
