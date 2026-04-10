// Windows.Identity.UUID.swift
// Native UUID parsing using Windows RPC library

#if os(Windows)
import WinSDK
public import Windows_Standard_Core

extension Windows_Standard_Core.Windows {
    /// Identity-related types for Windows.
    public enum Identity {}
}

extension Windows.Identity {
    /// Native UUID parsing using Windows RPC.
    public enum UUID {}
}

extension Windows.Identity.UUID {
    /// 16-byte tuple type matching RFC 4122 storage.
    public typealias Bytes = (
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
    )

    /// Parses RFC 4122 hyphenated format to 16 bytes.
    ///
    /// Uses Windows' native `UuidFromStringA` for optimal performance.
    /// Handles Windows' mixed-endian UUID struct and converts to RFC 4122 big-endian.
    ///
    /// - Parameter string: UUID string in format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
    /// - Returns: 16 bytes in big-endian order, or nil if parsing fails.
    public static func parse(_ string: String) -> Bytes? {
        var winUUID = WinSDK.UUID()
        let status = string.withCString { cString in
            // UuidFromStringA expects RPC_CSTR which is unsigned char*
            UuidFromStringA(RPC_CSTR(mutating: cString), &winUUID)
        }
        guard status == RPC_S_OK else { return nil }

        // Convert Windows mixed-endian to RFC 4122 big-endian
        // Windows UUID struct:
        //   Data1: 32-bit little-endian (bytes 0-3 reversed)
        //   Data2: 16-bit little-endian (bytes 4-5 reversed)
        //   Data3: 16-bit little-endian (bytes 6-7 reversed)
        //   Data4: 8 bytes big-endian (bytes 8-15 as-is)
        return (
            UInt8(truncatingIfNeeded: winUUID.Data1 >> 24),
            UInt8(truncatingIfNeeded: winUUID.Data1 >> 16),
            UInt8(truncatingIfNeeded: winUUID.Data1 >> 8),
            UInt8(truncatingIfNeeded: winUUID.Data1),
            UInt8(truncatingIfNeeded: winUUID.Data2 >> 8),
            UInt8(truncatingIfNeeded: winUUID.Data2),
            UInt8(truncatingIfNeeded: winUUID.Data3 >> 8),
            UInt8(truncatingIfNeeded: winUUID.Data3),
            winUUID.Data4.0, winUUID.Data4.1, winUUID.Data4.2, winUUID.Data4.3,
            winUUID.Data4.4, winUUID.Data4.5, winUUID.Data4.6, winUUID.Data4.7
        )
    }

    /// Formats 16 bytes to RFC 4122 hyphenated string.
    ///
    /// Uses Windows' native `UuidToStringA` for optimal performance.
    ///
    /// - Parameters:
    ///   - bytes: 16 bytes in big-endian order.
    ///   - uppercase: Whether to use uppercase hex digits (default: false).
    /// - Returns: Formatted UUID string.
    public static func unparse(_ bytes: Bytes, uppercase: Bool = false) -> String {
        // Convert RFC 4122 big-endian to Windows mixed-endian
        var winUUID = WinSDK.UUID(
            Data1: (UInt32(bytes.0) << 24) | (UInt32(bytes.1) << 16) |
                   (UInt32(bytes.2) << 8) | UInt32(bytes.3),
            Data2: (UInt16(bytes.4) << 8) | UInt16(bytes.5),
            Data3: (UInt16(bytes.6) << 8) | UInt16(bytes.7),
            Data4: (bytes.8, bytes.9, bytes.10, bytes.11,
                    bytes.12, bytes.13, bytes.14, bytes.15)
        )

        var stringPtr: RPC_CSTR? = nil
        let status = UuidToStringA(&winUUID, &stringPtr)
        guard status == RPC_S_OK, let ptr = stringPtr else {
            // Fallback to manual formatting
            return formatManually(bytes, uppercase: uppercase)
        }

        defer { RpcStringFreeA(&stringPtr) }

        let result = String(cString: ptr)
        return uppercase ? result.uppercased() : result.lowercased()
    }

    /// Manual formatting fallback.
    private static func formatManually(_ bytes: Bytes, uppercase: Bool) -> String {
        let hexChars: [Character] = uppercase
            ? Array("0123456789ABCDEF")
            : Array("0123456789abcdef")

        func hex(_ byte: UInt8) -> (Character, Character) {
            (hexChars[Int(byte >> 4)], hexChars[Int(byte & 0x0F)])
        }

        var result = ""
        result.reserveCapacity(36)

        // time_low
        for i in 0..<4 {
            let byte = withUnsafeBytes(of: bytes) { $0[i] }
            let (h, l) = hex(byte)
            result.append(h)
            result.append(l)
        }
        result.append("-")

        // time_mid
        for i in 4..<6 {
            let byte = withUnsafeBytes(of: bytes) { $0[i] }
            let (h, l) = hex(byte)
            result.append(h)
            result.append(l)
        }
        result.append("-")

        // time_hi_and_version
        for i in 6..<8 {
            let byte = withUnsafeBytes(of: bytes) { $0[i] }
            let (h, l) = hex(byte)
            result.append(h)
            result.append(l)
        }
        result.append("-")

        // clock_seq
        for i in 8..<10 {
            let byte = withUnsafeBytes(of: bytes) { $0[i] }
            let (h, l) = hex(byte)
            result.append(h)
            result.append(l)
        }
        result.append("-")

        // node
        for i in 10..<16 {
            let byte = withUnsafeBytes(of: bytes) { $0[i] }
            let (h, l) = hex(byte)
            result.append(h)
            result.append(l)
        }

        return result
    }
}
#endif
