import SwiftUI
import SnoopyCore

/// The settings screen described in spec/040-settings-management.md: every
/// user-managed configuration value, editable and auto-saved, with a
/// "Reset to Defaults" action, device pickers, and a connectivity test for
/// the base URL.
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Reset to Defaults", role: .destructive) {
                            viewModel.resetToDefaults()
                        }
                    }
                }
                .onAppear { viewModel.load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .notLoaded:
            ProgressView()
        case .fatalError(let message):
            ContentUnavailableView("Settings Unavailable", systemImage: "exclamationmark.triangle", description: Text(message))
        case .loaded(let items):
            Form {
                ForEach(items) { item in
                    SettingsRow(item: item, viewModel: viewModel)
                }
            }
        }
    }
}

private struct SettingsRow: View {
    let item: SettingsItem
    @ObservedObject var viewModel: SettingsViewModel
    @State private var text: String = ""
    @State private var connectivityMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            switch item.definition.type {
            case .deviceID:
                Picker(item.definition.displayName, selection: Binding(
                    get: { item.value },
                    set: { commit($0) }
                )) {
                    Text("System Default").tag("")
                    ForEach(viewModel.devices(for: item.definition.id)) { device in
                        Text(device.name).tag(device.id)
                    }
                }
            case .url:
                LabeledContent(item.definition.displayName) {
                    HStack {
                        TextField(item.definition.displayName, text: $text)
                            .onSubmit { commit(text) }
                        Button("Test") {
                            Task {
                                let result = await viewModel.testConnection(for: item.definition.id)
                                connectivityMessage = result.message
                            }
                        }
                    }
                }
            case .password:
                SecureField(item.definition.displayName, text: $text)
                    .onSubmit { commit(text) }
            case .number:
                TextField(item.definition.displayName, text: $text)
                    .onSubmit { commit(text) }
            }

            if let warning = item.warning {
                Text(warning)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .onAppear { text = item.value }
        .onChange(of: item.value) { _, newValue in text = newValue }
        .alert("Connection Test", isPresented: Binding(
            get: { connectivityMessage != nil },
            set: { if !$0 { connectivityMessage = nil } }
        )) {
            Button("OK") { connectivityMessage = nil }
        } message: {
            Text(connectivityMessage ?? "")
        }
    }

    private func commit(_ newValue: String) {
        _ = viewModel.update(keyID: item.definition.id, rawValue: newValue)
    }
}
