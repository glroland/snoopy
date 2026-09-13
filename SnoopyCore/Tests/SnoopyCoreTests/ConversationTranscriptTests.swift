import XCTest
@testable import SnoopyCore

@MainActor
final class ConversationTranscriptTests: XCTestCase {
    // Given the main listening view, when the user speaks into the app
    // while it is listening or the AI responds, then the messages written
    // to the transcription box must be in order of newest first.
    func testAppendInsertsNewestEntryFirst() {
        let transcript = ConversationTranscript()
        let first = TranscriptEntry(speaker: .user, text: "first")
        let second = TranscriptEntry(speaker: .assistant, text: "second")

        transcript.append(first)
        transcript.append(second)

        XCTAssertEqual(transcript.entries.map(\.text), ["second", "first"])
    }
}
