// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-standard open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
    public import WinSDK
#endif

// MARK: - File Open Mode

extension Windows.`32`.Kernel.File.Open {
    /// File access mode specifying read and/or write permissions.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Open.Mode`: a simple struct with two
    /// boolean flags indicating the desired access. Use the static
    /// conveniences for common cases.
    public struct Mode: Sendable, Hashable {
        /// Whether to open the file for reading.
        public let read: Bool

        /// Whether to open the file for writing.
        public let write: Bool

        /// Creates a mode with explicit read/write permissions.
        ///
        /// - Parameters:
        ///   - read: Whether to open for reading.
        ///   - write: Whether to open for writing.
        @inlinable
        public init(read: Bool, write: Bool) {
            self.read = read
            self.write = write
        }
    }
}

// MARK: - Standard Modes

extension Windows.`32`.Kernel.File.Open.Mode {
    /// Opens the file for reading only.
    public static let read = Self(read: true, write: false)

    /// Opens the file for writing only.
    public static let write = Self(read: false, write: true)

    /// Opens the file for reading and writing.
    public static let readWrite = Self(read: true, write: true)
}

// MARK: - Windows desired-access conversion

#if os(Windows)

    extension Windows.`32`.Kernel.File.Open.Mode {
        /// Converts the mode to Windows desired access flags.
        ///
        /// Maps the portable `Mode` flags to Win32 `GENERIC_READ` and `GENERIC_WRITE`.
        package var windowsDesiredAccess: DWORD {
            var access: DWORD = 0

            if read {
                access |= DWORD(GENERIC_READ)
            }
            if write {
                access |= DWORD(GENERIC_WRITE)
            }

            return access
        }
    }

#endif
