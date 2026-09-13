import XCTest
@testable import SnoopyCore

@MainActor
final class SplashScreenViewModelTests: XCTestCase {
    func testStartsHidden() {
        let viewModel = SplashScreenViewModel(scheduler: FakeSplashScheduler())
        XCTAssertEqual(viewModel.phase, .hidden)
    }

    func testPresentShowsThenDismissesAfterWait() async {
        let scheduler = FakeSplashScheduler()
        let viewModel = SplashScreenViewModel(scheduler: scheduler, visibleDuration: 1.5)

        let presenting = Task { await viewModel.present() }
        await Task.yield()
        XCTAssertEqual(viewModel.phase, .visible)
        XCTAssertEqual(scheduler.lastWaitedSeconds, 1.5)

        scheduler.resume()
        await presenting.value

        XCTAssertEqual(viewModel.phase, .dismissed)
    }

    // Splash content: title towards the top, and the copyright line at the
    // bottom, per spec/010-look-and-feel.md.
    func testSplashContentMatchesSpec() {
        XCTAssertEqual(SplashScreenViewModel.title, "Snoopy AI")
        XCTAssertEqual(SplashScreenViewModel.copyrightNotice, "Copyright 2026 Lee Roland.  All rights reserved.")
    }
}
