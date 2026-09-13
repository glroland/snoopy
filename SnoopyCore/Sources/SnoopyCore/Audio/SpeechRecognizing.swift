import Foundation

public enum SpeechRecognitionError: Error, Sendable {
    case unavailable
}

/// Abstraction over speech-to-text so `ListeningViewModel` can be tested
/// without real audio hardware.
public protocol SpeechRecognizing: AnyObject, Sendable {
    func startListening(
        onPartialResult: @escaping @Sendable (String) -> Void,
        onFinalResult: @escaping @Sendable (String) -> Void
    ) throws
    func stopListening()
}
