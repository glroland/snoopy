import XCTest
@testable import SnoopyCore

final class ConfigurationValidationTests: XCTestCase {
    // Given a configuration key of type URL String, when the key's value is
    // being loaded or updated, then the new value must be a valid URI where
    // the prefix is http or https.
    func testURLValidation() {
        XCTAssertTrue(ConfigurationValidator.validate("https://example.com/v1", as: .url).isSuccess)
        XCTAssertTrue(ConfigurationValidator.validate("http://example.com", as: .url).isSuccess)
        XCTAssertFalse(ConfigurationValidator.validate("ftp://example.com", as: .url).isSuccess)
        XCTAssertFalse(ConfigurationValidator.validate("not a url", as: .url).isSuccess)
        XCTAssertFalse(ConfigurationValidator.validate("", as: .url).isSuccess)
    }

    // Given a configuration key of type Password String, when the key's
    // value is being loaded or updated, then the new value must be numbers,
    // letters, and symbols with a maximum length of 5000 characters.
    func testPasswordValidation() {
        XCTAssertTrue(ConfigurationValidator.validate("no_key_needed", as: .password).isSuccess)
        XCTAssertTrue(ConfigurationValidator.validate("sk-Abc123!@#$%", as: .password).isSuccess)
        XCTAssertTrue(ConfigurationValidator.validate(String(repeating: "a", count: 5000), as: .password).isSuccess)
        XCTAssertFalse(ConfigurationValidator.validate(String(repeating: "a", count: 5001), as: .password).isSuccess)
    }

    // Given a configuration key of type Number, when the key's value is
    // being loaded or updated, then the new value must be a positive
    // integer less than 1000.
    func testNumberValidation() {
        XCTAssertTrue(ConfigurationValidator.validate("30", as: .number).isSuccess)
        XCTAssertTrue(ConfigurationValidator.validate("999", as: .number).isSuccess)
        XCTAssertFalse(ConfigurationValidator.validate("0", as: .number).isSuccess)
        XCTAssertFalse(ConfigurationValidator.validate("-5", as: .number).isSuccess)
        XCTAssertFalse(ConfigurationValidator.validate("1000", as: .number).isSuccess)
        XCTAssertFalse(ConfigurationValidator.validate("3.5", as: .number).isSuccess)
        XCTAssertFalse(ConfigurationValidator.validate("thirty", as: .number).isSuccess)
    }

    // Given a configuration key of type Device ID String, when the key's
    // value is being loaded or updated, then the new value must align with
    // how device IDs are uniquely identified in the underlying OS.
    func testDeviceIDValidation() {
        XCTAssertTrue(ConfigurationValidator.validate("", as: .deviceID).isSuccess, "empty means system default")
        XCTAssertTrue(ConfigurationValidator.validate("BuiltInMicrophoneDevice", as: .deviceID).isSuccess)
        XCTAssertFalse(ConfigurationValidator.validate("   ", as: .deviceID).isSuccess)
    }
}

extension Result {
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}
