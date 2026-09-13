import Foundation

public enum LLMServiceError: Error, Sendable {
    case badResponse
    case emptyResponse
}

/// Abstraction over an OpenAI-compatible chat completions endpoint, so
/// `ConversationEngine` can be tested without a network call.
public protocol ChatCompletionsService: Sendable {
    func complete(messages: [LLMMessage], baseURL: URL, apiKey: String, timeoutSeconds: Int) async throws -> String
}

/// Real implementation talking to any OpenAI-compatible `/chat/completions`
/// endpoint, per the "LLM inferencing must occur over an OpenAI compatible
/// API" constraint in spec/000-overview.md.
public struct OpenAICompatibleChatService: ChatCompletionsService {
    public init() {}

    public func complete(messages: [LLMMessage], baseURL: URL, apiKey: String, timeoutSeconds: Int) async throws -> String {
        var request = URLRequest(url: baseURL.appendingPathComponent("chat/completions"))
        request.httpMethod = "POST"
        request.timeoutInterval = TimeInterval(timeoutSeconds)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !apiKey.isEmpty {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        let payload: [String: Any] = [
            "model": "default",
            "messages": messages.map { ["role": $0.role.rawValue, "content": $0.content] }
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw LLMServiceError.badResponse
        }

        struct ChatResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable { let content: String }
                let message: Message
            }
            let choices: [Choice]
        }

        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw LLMServiceError.emptyResponse
        }
        return content
    }
}
