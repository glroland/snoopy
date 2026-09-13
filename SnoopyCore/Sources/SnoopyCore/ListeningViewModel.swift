import Foundation

/// Drives the main listening view described in spec/100-interact.md:
/// toggling listening on/off, and turning recognized speech into a
/// conversation turn (transcribe -> infer -> transcribe response).
@MainActor
public final class ListeningViewModel: ObservableObject {
    @Published public private(set) var isListening: Bool = false
    @Published public var isShowingSettings: Bool = false

    public let transcript: ConversationTranscript

    private let speechRecognizer: SpeechRecognizing
    private let conversationEngine: ConversationEngine

    public init(
        transcript: ConversationTranscript? = nil,
        speechRecognizer: SpeechRecognizing,
        conversationEngine: ConversationEngine
    ) {
        self.transcript = transcript ?? ConversationTranscript()
        self.speechRecognizer = speechRecognizer
        self.conversationEngine = conversationEngine
    }

    public func toggleListening() {
        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }

    public func startListening() {
        guard !isListening else { return }
        isListening = true
        try? speechRecognizer.startListening(
            onPartialResult: { _ in },
            onFinalResult: { [weak self] text in
                Task { @MainActor in
                    self?.isListening = false
                    await self?.handleRecognizedSpeech(text)
                }
            }
        )
    }

    public func stopListening() {
        guard isListening else { return }
        isListening = false
        speechRecognizer.stopListening()
    }

    public func openSettings() {
        isShowingSettings = true
    }

    /// Exposed (rather than private) so it can be driven directly in tests
    /// without going through the real speech recognizer's async callback.
    public func handleRecognizedSpeech(_ text: String) async {
        guard !text.isEmpty else { return }
        transcript.append(TranscriptEntry(speaker: .user, text: text))
        do {
            let response = try await conversationEngine.respond(to: text, history: transcript.entries)
            transcript.append(TranscriptEntry(speaker: .assistant, text: response))
        } catch {
            transcript.append(TranscriptEntry(speaker: .assistant, text: "Sorry, I couldn't reach the AI service."))
        }
    }
}
