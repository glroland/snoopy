import Foundation

/// Abstraction over waiting a duration, so splash timing can be driven
/// deterministically in tests instead of racing a real timer.
public protocol SplashScheduling: Sendable {
    func wait(seconds: TimeInterval) async
}

public struct RealSplashScheduler: SplashScheduling {
    public init() {}

    public func wait(seconds: TimeInterval) async {
        try? await Task.sleep(nanoseconds: UInt64(max(0, seconds) * 1_000_000_000))
    }
}

public enum SplashPhase: Equatable, Sendable {
    case hidden
    case visible
    case dismissed
}

/// The brief title screen shown on launch: fades in, holds, fades out. See
/// spec/010-look-and-feel.md.
@MainActor
public final class SplashScreenViewModel: ObservableObject {
    public static let title = "Snoopy AI"
    public static let copyrightNotice = "Copyright 2026 Lee Roland.  All rights reserved."

    @Published public private(set) var phase: SplashPhase = .hidden

    private let scheduler: SplashScheduling
    private let visibleDuration: TimeInterval

    public init(scheduler: SplashScheduling = RealSplashScheduler(), visibleDuration: TimeInterval = 1.5) {
        self.scheduler = scheduler
        self.visibleDuration = visibleDuration
    }

    public func present() async {
        guard phase == .hidden else { return }
        phase = .visible
        await scheduler.wait(seconds: visibleDuration)
        phase = .dismissed
    }
}
