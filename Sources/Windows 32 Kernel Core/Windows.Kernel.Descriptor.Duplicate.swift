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

extension Windows.Kernel.Descriptor {
    /// Windows handle duplication operations.
    ///
    /// Wraps `DuplicateHandle`. The new handle refers to the same kernel
    /// object with the same access rights.
    public enum Duplicate: Sendable {}
}

extension Windows.Kernel.Descriptor.Duplicate {
    /// Errors that can occur during Windows handle duplication.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The source handle is invalid.
        case handle(Windows.Kernel.Descriptor.Validity.Error)

        /// Per-process handle limit reached.
        case tooManyOpen

        /// A platform-specific error.
        case platform(Error_Primitives.Error)
    }
}
