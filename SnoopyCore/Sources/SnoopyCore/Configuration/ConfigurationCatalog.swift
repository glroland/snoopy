import Foundation

/// The set of configurable values defined in spec/030-configurable-values.md.
public enum ConfigurationCatalog {
    public static let microphone = ConfigurationKeyDefinition(
        id: "microphone", displayName: "Microphone", type: .deviceID, defaultValue: "", isUserManaged: true
    )
    public static let speaker = ConfigurationKeyDefinition(
        id: "speaker", displayName: "Speaker", type: .deviceID, defaultValue: "", isUserManaged: true
    )
    public static let openAIBaseURL = ConfigurationKeyDefinition(
        id: "openAIBaseURL", displayName: "OpenAI Base URL", type: .url,
        defaultValue: "https://evolvewired.home.glroland.com/v1", isUserManaged: true
    )
    public static let openAIAPIKey = ConfigurationKeyDefinition(
        id: "openAIAPIKey", displayName: "OpenAI API Key", type: .password,
        defaultValue: "no_key_needed", isUserManaged: true
    )
    public static let openAITimeoutSeconds = ConfigurationKeyDefinition(
        id: "openAITimeoutSeconds", displayName: "OpenAI Timeout (Seconds)", type: .number,
        defaultValue: "30", isUserManaged: true
    )

    public static let standard: [ConfigurationKeyDefinition] = [
        microphone, speaker, openAIBaseURL, openAIAPIKey, openAITimeoutSeconds
    ]
}
