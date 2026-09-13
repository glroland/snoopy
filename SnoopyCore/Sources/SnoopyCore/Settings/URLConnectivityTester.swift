import Foundation

public struct URLConnectivityResult: Equatable, Sendable {
    public let succeeded: Bool
    public let message: String

    public init(succeeded: Bool, message: String) {
        self.succeeded = succeeded
        self.message = message
    }
}

/// Tests whether a configured OpenAI-compatible base URL can be reached,
/// per the "test button" behavior in spec/040-settings-management.md.
public protocol URLConnectivityTesting: Sendable {
    func testConnection(to url: URL, apiKey: String) async -> URLConnectivityResult
}

public struct HTTPURLConnectivityTester: URLConnectivityTesting {
    public init() {}

    public func testConnection(to url: URL, apiKey: String) async -> URLConnectivityResult {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if !apiKey.isEmpty {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                return URLConnectivityResult(succeeded: false, message: "No HTTP response was received.")
            }
            if (200..<300).contains(http.statusCode) {
                return URLConnectivityResult(succeeded: true, message: "Connected successfully (HTTP \(http.statusCode)).")
            }
            return URLConnectivityResult(succeeded: false, message: "Server responded with HTTP \(http.statusCode).")
        } catch {
            return URLConnectivityResult(succeeded: false, message: "Connection failed: \(error.localizedDescription)")
        }
    }
}
