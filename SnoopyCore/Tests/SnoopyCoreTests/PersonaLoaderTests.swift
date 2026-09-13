import XCTest
@testable import SnoopyCore

final class PersonaLoaderTests: XCTestCase {
    private func makeTempDirectory() -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func writePersona(_ json: String, named name: String, in directory: URL) {
        let personaDir = directory.appendingPathComponent(name)
        try! FileManager.default.createDirectory(at: personaDir, withIntermediateDirectories: true)
        try! json.write(to: personaDir.appendingPathComponent("persona.json"), atomically: true, encoding: .utf8)
    }

    func testLoadsWellFormedPersonasFromDirectory() {
        let directory = makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        writePersona(#"{"id": "family-listener", "name": "Family Listener", "systemPrompt": "Listen and comment."}"#, named: "FamilyListener", in: directory)

        let (personas, warnings) = PersonaLoader.loadPersonas(from: directory)

        XCTAssertTrue(warnings.isEmpty)
        XCTAssertTrue(personas.contains { $0.id == "family-listener" && $0.systemPrompt == "Listen and comment." })
    }

    func testMalformedPersonaIsSkippedWithWarning() {
        let directory = makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        writePersona(#"{ this is not valid json"#, named: "Broken", in: directory)

        let (personas, warnings) = PersonaLoader.loadPersonas(from: directory)

        XCTAssertFalse(personas.contains { $0.id == "Broken" })
        XCTAssertEqual(warnings.count, 1)
        XCTAssertEqual(warnings.first?.directoryName, "Broken")
    }

    // The Default persona is always provided with the application, even
    // when the bundled directory doesn't define one.
    func testDefaultPersonaIsAlwaysPresentEvenWhenDirectoryOmitsIt() {
        let directory = makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        writePersona(#"{"id": "other", "name": "Other", "systemPrompt": "Be other."}"#, named: "Other", in: directory)

        let (personas, _) = PersonaLoader.loadPersonas(from: directory)

        XCTAssertTrue(personas.contains { $0.id == Persona.default.id })
    }

    func testDirectoryProvidedDefaultOverridesHardcodedFallback() {
        let directory = makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        writePersona(#"{"id": "default", "name": "Custom Default", "systemPrompt": "Custom prompt."}"#, named: "Default", in: directory)

        let (personas, _) = PersonaLoader.loadPersonas(from: directory)

        let defaultPersona = personas.first { $0.id == Persona.default.id }
        XCTAssertEqual(defaultPersona?.systemPrompt, "Custom prompt.")
    }
}
