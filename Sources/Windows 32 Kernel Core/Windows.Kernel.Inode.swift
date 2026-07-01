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
    /// Filesystem inode number.
    ///
    /// Mirrors `ISO_9945.Kernel.Inode`. On Windows this is synthesized from
    /// the file index (`nFileIndexHigh`/`nFileIndexLow`), which uniquely
    /// identifies a file on its volume.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// if stats1.inode == stats2.inode && stats1.device == stats2.device {
    ///     // Both paths refer to the same file (hard links or same path)
    /// }
    /// ```
    public struct Inode: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt64

        /// Creates an inode from a raw value.
        @inlinable
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        /// Creates an inode from a UInt64 value.
        @inlinable
        public init(_ value: UInt64) {
            self.rawValue = value
        }
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Windows.`32`.Kernel.Inode: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: UInt64) {
        self.rawValue = value
    }
}

// MARK: - CustomStringConvertible

extension Windows.`32`.Kernel.Inode: CustomStringConvertible {
    public var description: Swift.String {
        "\(rawValue)"
    }
}
