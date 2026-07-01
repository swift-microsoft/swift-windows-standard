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

public import Error_Primitives

extension Windows.`32`.Kernel.Environment {
    /// Errors that can occur during environment operations.
    ///
    /// Mirrors `ISO_9945.Kernel.Environment.Error`.
    public enum Error: Swift.Error, Sendable {
        case permission(Windows.`32`.Kernel.Permission.Error)
        case invalid(Invalid)
        case platform(Error_Primitives.Error)
    }
}

// MARK: - Invalid

extension Windows.`32`.Kernel.Environment.Error {
    /// Invalid argument errors specific to environment operations.
    public enum Invalid: Swift.Error, Sendable, Equatable, Hashable {
        /// The variable name is empty.
        case emptyName
        /// The variable name contains an equals sign.
        case nameContainsEquals
    }
}

// MARK: - Code Mapping

extension Windows.`32`.Kernel.Environment.Error {
    /// Creates an error from a canonical error code.
    ///
    /// Maps permission codes to the semantic `permission` case; everything
    /// else lands in `platform`.
    public init(code: Error_Primitives.Error.Code) {
        if let permission = Windows.`32`.Kernel.Permission.Error(code: code) {
            self = .permission(permission)
        } else {
            self = .platform(Error_Primitives.Error(code: code))
        }
    }
}

// MARK: - Equatable

extension Windows.`32`.Kernel.Environment.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.permission(let l), .permission(let r)): return l == r
        case (.invalid(let l), .invalid(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

// MARK: - CustomStringConvertible

extension Windows.`32`.Kernel.Environment.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .permission(let e): return "permission: \(e)"
        case .invalid(let e): return "invalid: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}

extension Windows.`32`.Kernel.Environment.Error.Invalid: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .emptyName: return "empty variable name"
        case .nameContainsEquals: return "variable name contains '='"
        }
    }
}
