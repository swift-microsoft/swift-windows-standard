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

extension Windows.Kernel.Descriptor.Validity.Error {
    /// Limit scope for Windows handle exhaustion.
    public enum Limit: Sendable, Equatable, Hashable {
        /// Per-process handle limit reached (`ERROR_TOO_MANY_OPEN_FILES`).
        case process

        /// System-wide handle limit reached.
        case system
    }
}

extension Windows.Kernel.Descriptor.Validity.Error.Limit: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .process:
            return "too many open handles in process"
        case .system:
            return "too many open handles in system"
        }
    }
}
