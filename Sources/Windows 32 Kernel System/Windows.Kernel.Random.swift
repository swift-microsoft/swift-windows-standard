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
    public import Random_Primitives

    // MARK: - Windows BCryptGenRandom syscall

    extension Windows.`32`.Kernel.Random {
        /// Fills a buffer with cryptographically secure random bytes using
        /// `BCryptGenRandom` from the Windows CNG (Cryptography Next Generation) API.
        ///
        /// - Parameter buffer: The buffer to fill with random bytes.
        /// - Throws: `Random.Error` on NTSTATUS failure.
        public static func bCryptGenRandom(
            _ buffer: UnsafeMutableRawBufferPointer
        ) throws(Random.Error) {
            guard let baseAddress = buffer.baseAddress, buffer.count > 0 else { return }

            let status = BCryptGenRandom(
                nil,  // Use default algorithm provider
                baseAddress.assumingMemoryBound(to: UInt8.self),
                ULONG(buffer.count),
                ULONG(BCRYPT_USE_SYSTEM_PREFERRED_RNG)
            )

            if status != 0 {
                throw .systemError(status)
            }
        }

        /// Fills a mutable span with cryptographically secure random bytes using
        /// `BCryptGenRandom`.
        ///
        /// - Parameter span: The span to fill with random bytes.
        /// - Throws: `Random.Error` on NTSTATUS failure.
        @inlinable
        public static func bCryptGenRandom(
            _ span: inout MutableSpan<UInt8>
        ) throws(Random.Error) {
            try span.withUnsafeMutableBytes { buffer throws(Random.Error) in
                try bCryptGenRandom(buffer)
            }
        }

        /// Generates a random `UInt64` using `BCryptGenRandom`.
        ///
        /// - Returns: A random `UInt64`, or `nil` on failure.
        public static func uint64() -> UInt64? {
            var value: UInt64 = 0
            do {
                try withUnsafeMutableBytes(of: &value) { buffer throws(Random.Error) in
                    try bCryptGenRandom(buffer)
                }
                return value
            } catch {
                return nil
            }
        }

        /// Generates a random `UInt32` using `BCryptGenRandom`.
        ///
        /// - Returns: A random `UInt32`, or `nil` on failure.
        public static func uint32() -> UInt32? {
            var value: UInt32 = 0
            do {
                try withUnsafeMutableBytes(of: &value) { buffer throws(Random.Error) in
                    try bCryptGenRandom(buffer)
                }
                return value
            } catch {
                return nil
            }
        }
    }
#endif
