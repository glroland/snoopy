import Foundation

public struct PersonaLoadWarning: Equatable, Sendable {
    public let directoryName: String
    public let message: String

    public init(directoryName: String, message: String) {
        self.directoryName = directoryName
        self.message = message
    }
}

/// Loads personas from a directory structure: one subdirectory per persona,
/// each containing a `persona.json` with `id`, `name`, and `systemPrompt`.
/// See the "completely configurable via a directory structure" constraint in
/// spec/000-overview.md.
public enum PersonaLoader {
    private struct PersonaFile: Decodable {
        let id: String
        let name: String
        let systemPrompt: String
    }

    public static func loadPersonas(
        from directoryURL: URL,
        fileManager: FileManager = .default
    ) -> (personas: [Persona], warnings: [PersonaLoadWarning]) {
        var personas: [Persona] = []
        var warnings: [PersonaLoadWarning] = []

        let entries = (try? fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)) ?? []
        for entry in entries.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: entry.path, isDirectory: &isDirectory), isDirectory.boolValue else {
                continue
            }

            let personaFileURL = entry.appendingPathComponent("persona.json")
            guard let data = try? Data(contentsOf: personaFileURL) else {
                warnings.append(PersonaLoadWarning(directoryName: entry.lastPathComponent, message: "Missing persona.json"))
                continue
            }
            do {
                let file = try JSONDecoder().decode(PersonaFile.self, from: data)
                personas.append(Persona(id: file.id, name: file.name, systemPrompt: file.systemPrompt))
            } catch {
                warnings.append(PersonaLoadWarning(
                    directoryName: entry.lastPathComponent,
                    message: "Malformed persona.json: \(error.localizedDescription)"
                ))
            }
        }

        if !personas.contains(where: { $0.id == Persona.default.id }) {
            personas.append(Persona.default)
        }

        return (personas, warnings)
    }
}
