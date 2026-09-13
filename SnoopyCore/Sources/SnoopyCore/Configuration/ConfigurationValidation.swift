import Foundation

public enum ConfigurationValidationError: Error, Equatable, Sendable {
    case invalidURL
    case invalidPassword
    case invalidNumber
    case invalidDeviceID
}

public enum ConfigurationValidator {
    public static func validate(_ rawValue: String, as type: ConfigurationValueType) -> Result<Void, ConfigurationValidationError> {
        switch type {
        case .url:
            return validateURL(rawValue)
        case .password:
            return validatePassword(rawValue)
        case .number:
            return validateNumber(rawValue)
        case .deviceID:
            return validateDeviceID(rawValue)
        }
    }

    private static func validateURL(_ raw: String) -> Result<Void, ConfigurationValidationError> {
        guard let url = URL(string: raw),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              url.host != nil
        else {
            return .failure(.invalidURL)
        }
        return .success(())
    }

    private static func validatePassword(_ raw: String) -> Result<Void, ConfigurationValidationError> {
        guard raw.count <= 5000 else { return .failure(.invalidPassword) }
        let allowed = CharacterSet.alphanumerics
            .union(.punctuationCharacters)
            .union(.symbols)
        guard raw.unicodeScalars.allSatisfy({ allowed.contains($0) }) else {
            return .failure(.invalidPassword)
        }
        return .success(())
    }

    private static func validateNumber(_ raw: String) -> Result<Void, ConfigurationValidationError> {
        guard let value = Int(raw), value > 0, value < 1000 else {
            return .failure(.invalidNumber)
        }
        return .success(())
    }

    /// Device identifiers are opaque, OS-assigned unique IDs (e.g.
    /// `AVCaptureDevice.uniqueID` on iOS, a CoreAudio persistent UID on
    /// macOS) with no shared format to check further against, so an empty
    /// value (meaning "use the system default") or any non-blank string is
    /// accepted.
    private static func validateDeviceID(_ raw: String) -> Result<Void, ConfigurationValidationError> {
        if raw.isEmpty { return .success(()) }
        guard !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.invalidDeviceID)
        }
        return .success(())
    }
}
