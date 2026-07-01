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
    /// Errors that can occur during socket operations.
    public enum Error: Swift.Error, Sendable {
        /// A platform-specific error.
        case platform(Error_Primitives.Error)
    }
}

// MARK: - Equatable

extension Windows.`32`.Kernel.Socket.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.platform(let l), .platform(let r)): return l == r
        }
    }
}

// MARK: - CustomStringConvertible

extension Windows.`32`.Kernel.Socket.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .platform(let e): return "\(e)"
        }
    }
}
