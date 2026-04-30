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

extension Windows.`32`.Kernel.Descriptor.Validity {
    /// Windows handle validity errors.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// The handle is invalid (`ERROR_INVALID_HANDLE`).
        case invalid

        /// Handle exhaustion (`ERROR_TOO_MANY_OPEN_FILES`).
        case limit(Limit)
    }
}

extension Windows.`32`.Kernel.Descriptor.Validity.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .invalid:
            return "invalid handle"
        case .limit(let limit):
            return limit.description
        }
    }
}
