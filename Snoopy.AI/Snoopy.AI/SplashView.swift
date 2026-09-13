import SwiftUI
import SnoopyCore

/// The brief title screen shown on launch, per spec/010-look-and-feel.md:
/// title towards the top, the app logo in the middle, and the copyright
/// notice at the bottom, fading in and back out.
struct SplashView: View {
    @ObservedObject var viewModel: SplashScreenViewModel

    var body: some View {
        VStack {
            Text(SplashScreenViewModel.title)
                .font(.largeTitle.bold())
                .padding(.top, 48)

            Spacer()

            Image(systemName: "waveform.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(.tint)

            Spacer()

            Text(SplashScreenViewModel.copyrightNotice)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(viewModel.phase == .visible ? 1 : 0)
        .animation(.easeInOut(duration: 0.4), value: viewModel.phase)
        .task {
            await viewModel.present()
        }
    }
}
