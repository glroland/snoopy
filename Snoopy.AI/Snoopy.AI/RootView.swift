import SwiftUI
import SnoopyCore

struct RootView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var splash = SplashScreenViewModel()

    var body: some View {
        ZStack {
            ListeningView(viewModel: environment.listening, settings: environment.settings)

            if splash.phase != .dismissed {
                SplashView(viewModel: splash)
            }
        }
    }
}
