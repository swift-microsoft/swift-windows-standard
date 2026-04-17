// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
public import WinSDK

// MARK: - Windows Secure Random

extension Windows.Kernel.Random {
    /// Fills a buffer with cryptographically secure random bytes.
    ///
    /// Uses BCryptGenRandom from the Windows CNG (Cryptography Next Generation) API.
    ///
    /// - Parameter buffer: The buffer to fill with random bytes.
    /// - Returns: True on success, false on failure.
    @discardableResult
    public static func fill(_ buffer: UnsafeMutableRawBufferPointer) -> Bool {
        guard let baseAddress = buffer.baseAddress else {
            return buffer.count == 0
        }

        let status = BCryptGenRandom(
            nil,  // Use default algorithm provider
            baseAddress.assumingMemoryBound(to: UInt8.self),
            ULONG(buffer.count),
            ULONG(BCRYPT_USE_SYSTEM_PREFERRED_RNG)
        )

        return status == 0  // STATUS_SUCCESS
    }

    /// Fills a mutable span with cryptographically secure random bytes.
    ///
    /// - Parameter span: The span to fill with random bytes.
    /// - Returns: True on success, false on failure.
    @discardableResult
    @inlinable
    public static func fill(_ span: inout MutableSpan<UInt8>) -> Bool {
        span.withUnsafeMutableBytes { buffer in
            fill(buffer)
        }
    }

    /// Generates a random UInt64.
    ///
    /// - Returns: A random UInt64, or nil on failure.
    public static func uint64() -> UInt64? {
        var value: UInt64 = 0
        let success = withUnsafeMutableBytes(of: &value) { buffer in
            fill(buffer)
        }
        return success ? value : nil
    }

    /// Generates a random UInt32.
    ///
    /// - Returns: A random UInt32, or nil on failure.
    public static func uint32() -> UInt32? {
        var value: UInt32 = 0
        let success = withUnsafeMutableBytes(of: &value) { buffer in
            fill(buffer)
        }
        return success ? value : nil
    }
}

#endif
