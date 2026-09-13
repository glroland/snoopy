import Foundation

/// Newest-first message history shown in the transcription box.
@MainActor
public final class ConversationTranscript: ObservableObject {
    @Published public private(set) var entries: [TranscriptEntry] = []

    public init() {}

    public func append(_ entry: TranscriptEntry) {
        entries.insert(entry, at: 0)
    }
}
