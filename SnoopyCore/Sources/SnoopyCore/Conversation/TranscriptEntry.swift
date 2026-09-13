import Foundation

/// One line in the on-screen transcription box. See spec/100-interact.md.
public struct TranscriptEntry: Identifiable, Equatable, Sendable {
    public enum Speaker: Sendable {
        case user
        case assistant
    }

    public let id: UUID
    public let speaker: Speaker
    public let text: String
    public let timestamp: Date

    public init(id: UUID = UUID(), speaker: Speaker, text: String, timestamp: Date = Date()) {
        self.id = id
        self.speaker = speaker
        self.text = text
        self.timestamp = timestamp
    }
}
