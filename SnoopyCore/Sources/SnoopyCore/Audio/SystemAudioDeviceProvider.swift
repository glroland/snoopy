import Foundation
import AVFoundation
#if os(macOS)
import CoreAudio
#endif

/// Enumerates the microphones/speakers actually available on the current
/// device, for the device pickers described in
/// spec/040-settings-management.md.
public struct SystemAudioDeviceProvider: AudioDeviceProviding {
    public init() {}

    public func inputDevices() -> [AudioDevice] {
        #if os(iOS)
        return (AVAudioSession.sharedInstance().availableInputs ?? []).map {
            AudioDevice(id: $0.uid, name: $0.portName)
        }
        #elseif os(macOS)
        return Self.coreAudioDevices(scope: kAudioObjectPropertyScopeInput)
        #else
        return []
        #endif
    }

    public func outputDevices() -> [AudioDevice] {
        #if os(iOS)
        // iOS does not expose a selectable list of output devices the way
        // it does inputs; the currently active route is the closest
        // equivalent of "the applicable devices available on the system".
        return AVAudioSession.sharedInstance().currentRoute.outputs.map {
            AudioDevice(id: $0.uid, name: $0.portName)
        }
        #elseif os(macOS)
        return Self.coreAudioDevices(scope: kAudioObjectPropertyScopeOutput)
        #else
        return []
        #endif
    }

    #if os(macOS)
    private static func coreAudioDevices(scope: AudioObjectPropertyScope) -> [AudioDevice] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var propertySize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propertySize)
        guard status == noErr, propertySize > 0 else { return [] }

        let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
        status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propertySize, &deviceIDs)
        guard status == noErr else { return [] }

        return deviceIDs.compactMap { deviceID in
            guard hasStreams(deviceID: deviceID, scope: scope) else { return nil }
            guard let name = stringProperty(deviceID: deviceID, selector: kAudioObjectPropertyName),
                  let uid = stringProperty(deviceID: deviceID, selector: kAudioDevicePropertyDeviceUID)
            else { return nil }
            return AudioDevice(id: uid, name: name)
        }
    }

    private static func hasStreams(deviceID: AudioDeviceID, scope: AudioObjectPropertyScope) -> Bool {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: scope,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0
        let status = AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &size)
        return status == noErr && size > 0
    }

    private static func stringProperty(deviceID: AudioDeviceID, selector: AudioObjectPropertySelector) -> String? {
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var value: Unmanaged<CFString>?
        var size = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
        let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &value)
        guard status == noErr, let value else { return nil }
        return value.takeRetainedValue() as String
    }
    #endif
}
