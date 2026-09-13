import Combine
import Foundation
import SnoopyCore

/// Assembles the real, non-test collaborators the app runs with: the
/// configuration store, the persona loaded from the bundled directory, and
/// the view models built on top of them.
@MainActor
final class AppEnvironment: ObservableObject {
    let configuration: ConfigurationStore
    let settings: SettingsViewModel
    let listening: ListeningViewModel

    init() {
        let configuration = ConfigurationStore()
        configuration.load()

        let persona = AppEnvironment.loadPersona()
        let conversationEngine = ConversationEngine(
            persona: persona,
            chatService: OpenAICompatibleChatService(),
            configuration: configuration
        )

        self.configuration = configuration
        self.settings = SettingsViewModel(configuration: configuration)
        self.listening = ListeningViewModel(
            speechRecognizer: OnDeviceSpeechRecognizer(),
            conversationEngine: conversationEngine
        )
    }

    private static func loadPersona() -> Persona {
        guard let directoryURL = Bundle.main.url(forResource: "Personas", withExtension: nil) else {
            return .default
        }
        let (personas, _) = PersonaLoader.loadPersonas(from: directoryURL)
        return personas.first { $0.id == Persona.default.id } ?? .default
    }
}
