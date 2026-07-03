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

extension Windows.`32`.Kernel.Socket {
    /// Listen backlog size.
    ///
    /// Specifies the maximum length of the queue of pending connections
    /// for the `listen` call. Type shape mirrors `ISO_9945.Kernel.Socket.Backlog`
    /// (the cross-platform contract); the Windows `.max` platform value lives in
    /// the Kernel Socket target (`Windows.Kernel.Socket.Listen`).
    public struct Backlog: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        /// Creates a backlog from a raw value.
        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Creates a backlog from an Int32 value.
        @inlinable
        public init(_ value: Int32) {
            self.rawValue = value
        }
    }
}

extension Windows.`32`.Kernel.Socket.Backlog {
    // MARK: - Common Values

    /// Default backlog (128).
    public static let `default` = Backlog(128)

    /// Small backlog (16), suitable for low-traffic services.
    public static let small = Backlog(16)

    /// Large backlog (4096), for high-traffic servers.
    public static let large = Backlog(4096)
}

// MARK: - ExpressibleByIntegerLiteral

extension Windows.`32`.Kernel.Socket.Backlog: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Int32) {
        self.rawValue = value
    }
}

// MARK: - CustomStringConvertible

extension Windows.`32`.Kernel.Socket.Backlog: CustomStringConvertible {
    public var description: Swift.String {
        "\(rawValue)"
    }
}
