import Foundation

/// An AI persona: its identity plus the system prompt that governs how it
/// interprets and responds to user input. See spec/020-ai-personna-design.md.
public struct Persona: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let systemPrompt: String

    public init(id: String, name: String, systemPrompt: String) {
        self.id = id
        self.name = name
        self.systemPrompt = systemPrompt
    }

    /// The persona always provided with the application, regardless of what
    /// (if anything) is present in the bundled/compiled persona directory.
    public static let `default` = Persona(
        id: "default",
        name: "Snoopy",
        systemPrompt: """
        You are Snoopy, a warm and attentive voice assistant. The user is speaking to you \
        out loud, often with their hands full, so keep replies conversational, concise, and \
        easy to follow when heard rather than read.
        """
    )
}
