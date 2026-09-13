import Foundation
@testable import SnoopyCore

final class FakeAudioDeviceProvider: AudioDeviceProviding, @unchecked Sendable {
    var inputs: [AudioDevice] = []
    var outputs: [AudioDevice] = []

    func inputDevices() -> [AudioDevice] { inputs }
    func outputDevices() -> [AudioDevice] { outputs }
}

final class FakeURLConnectivityTester: URLConnectivityTesting, @unchecked Sendable {
    var result = URLConnectivityResult(succeeded: true, message: "ok")
    private(set) var lastRequestedURL: URL?
    private(set) var lastAPIKey: String?

    func testConnection(to url: URL, apiKey: String) async -> URLConnectivityResult {
        lastRequestedURL = url
        lastAPIKey = apiKey
        return result
    }
}

final class FakeChatCompletionsService: ChatCompletionsService, @unchecked Sendable {
    var responseText = "a canned reply"
    var errorToThrow: Error?
    private(set) var lastMessages: [LLMMessage]?
    private(set) var callCount = 0

    func complete(messages: [LLMMessage], baseURL: URL, apiKey: String, timeoutSeconds: Int) async throws -> String {
        callCount += 1
        lastMessages = messages
        if let errorToThrow { throw errorToThrow }
        return responseText
    }
}

final class FakeSpeechRecognizer: SpeechRecognizing, @unchecked Sendable {
    private(set) var startCallCount = 0
    private(set) var stopCallCount = 0
    var onFinalResultHandler: ((@Sendable (String) -> Void) -> Void)?

    func startListening(
        onPartialResult: @escaping @Sendable (String) -> Void,
        onFinalResult: @escaping @Sendable (String) -> Void
    ) throws {
        startCallCount += 1
        onFinalResultHandler?(onFinalResult)
    }

    func stopListening() {
        stopCallCount += 1
    }
}

final class FakeSplashScheduler: SplashScheduling, @unchecked Sendable {
    private(set) var lastWaitedSeconds: TimeInterval?
    private var continuation: CheckedContinuation<Void, Never>?

    func wait(seconds: TimeInterval) async {
        lastWaitedSeconds = seconds
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    func resume() {
        continuation?.resume()
        continuation = nil
    }
}
