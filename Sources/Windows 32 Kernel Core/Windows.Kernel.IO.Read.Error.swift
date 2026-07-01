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

extension Windows.`32`.Kernel.IO.Read {
    /// Errors that can occur during read operations.
    public enum Error: Swift.Error, Sendable {
        case handle(Windows.`32`.Kernel.Descriptor.Validity.Error)
        case blocking(Windows.`32`.Kernel.IO.Blocking.Error)
        case platform(Error_Primitives.Error)
    }
}

// MARK: - Equatable

extension Windows.`32`.Kernel.IO.Read.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.handle(let l), .handle(let r)): return l == r
        case (.blocking(let l), .blocking(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

// MARK: - CustomStringConvertible

extension Windows.`32`.Kernel.IO.Read.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .handle(let e): return "handle: \(e)"
        case .blocking(let e): return "blocking: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}
