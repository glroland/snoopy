import SwiftUI
import SnoopyCore

/// The main interaction view described in spec/100-interact.md: a large
/// microphone toggle, a background that darkens while listening, and a
/// scrollable, newest-first transcription box below it.
struct ListeningView: View {
    @ObservedObject var viewModel: ListeningViewModel
    @ObservedObject var settings: SettingsViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Button {
                    viewModel.toggleListening()
                } label: {
                    Image(systemName: "mic.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundStyle(viewModel.isListening ? .red : .accentColor)
                }
                .buttonStyle(.plain)

                if viewModel.isListening {
                    Text("Listening...")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }

                Spacer()

                TranscriptView(transcript: viewModel.transcript)
                    .frame(maxHeight: 320)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(viewModel.isListening ? Color.black.opacity(0.85) : Color.white)
            .toolbar {
                ToolbarItem {
                    Button {
                        viewModel.openSettings()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingSettings) {
                SettingsView(viewModel: settings)
            }
        }
    }
}

private struct TranscriptView: View {
    @ObservedObject var transcript: ConversationTranscript

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(transcript.entries) { entry in
                    Text(entry.text)
                        .font(entry.speaker == .user ? .body : .body.italic())
                        .foregroundStyle(entry.speaker == .user ? .primary : .secondary)
                        .frame(maxWidth: .infinity, alignment: entry.speaker == .user ? .trailing : .leading)
                }
            }
            .padding(.vertical, 8)
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
