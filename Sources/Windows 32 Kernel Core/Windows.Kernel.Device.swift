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

extension Windows.`32`.Kernel {
    /// Device ID.
    ///
    /// Mirrors `ISO_9945.Kernel.Device`. On Windows this is synthesized from
    /// the volume serial number and identifies the volume containing a file.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// if stats1.device == stats2.device {
    ///     // Both files are on the same volume
    /// }
    /// ```
    public struct Device: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt64

        /// Creates a device ID from a raw value.
        @inlinable
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        /// Creates a device ID from a UInt64 value.
        @inlinable
        public init(_ value: UInt64) {
            self.rawValue = value
        }
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Windows.`32`.Kernel.Device: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: UInt64) {
        self.rawValue = value
    }
}
