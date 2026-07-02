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

extension Windows.`32`.Kernel.File.Clone.Error {
    /// Raw syscall-layer clone failure, mapped to the semantic ``Error``
    /// via ``Error/init(from:)``. Mirrors
    /// `ISO_9945.Kernel.File.Clone.Error.Syscall` per [PLAT-ARCH-008c].
    public enum Syscall: Swift.Error, Sendable {
        /// A platform error with the failing operation.
        case platform(code: Error_Primitives.Error.Code, operation: Operation)

        /// The operation is not supported on this platform/filesystem.
        case notSupported(operation: Operation)
    }
}
