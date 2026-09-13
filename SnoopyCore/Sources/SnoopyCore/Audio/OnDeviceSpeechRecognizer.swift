import Foundation
import AVFoundation
import Speech

/// Real speech-to-text, using Apple's on-device recognition so no cloud
/// dependency is required (see the constraint in spec/000-overview.md).
/// English only, per spec/100-interact.md.
public final class OnDeviceSpeechRecognizer: SpeechRecognizing, @unchecked Sendable {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    public init() {}

    public func startListening(
        onPartialResult: @escaping @Sendable (String) -> Void,
        onFinalResult: @escaping @Sendable (String) -> Void
    ) throws {
        guard let recognizer, recognizer.isAvailable else {
            throw SpeechRecognitionError.unavailable
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = true
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            if let result {
                if result.isFinal {
                    onFinalResult(result.bestTranscription.formattedString)
                    self?.stopListening()
                } else {
                    onPartialResult(result.bestTranscription.formattedString)
                }
            }
            if error != nil {
                self?.stopListening()
            }
        }
    }

    public func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
    }
}
