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

extension Windows.`32`.Kernel.Directory.Working {
    /// Errors from working directory operations.
    public enum Error: Swift.Error, Sendable {
        /// Path resolution error (directory not found, etc.).
        case path(Path.Resolution.Error)

        /// Platform-specific error.
        case platform(Error_Primitives.Error)
    }
}

// MARK: - Equatable

extension Windows.`32`.Kernel.Directory.Working.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.path(let l), .path(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

// MARK: - CustomStringConvertible

extension Windows.`32`.Kernel.Directory.Working.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .path(let e): return "working directory: \(e)"
        case .platform(let e): return "working directory: \(e)"
        }
    }
}
