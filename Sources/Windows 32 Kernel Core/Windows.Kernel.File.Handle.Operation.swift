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

extension Windows.`32`.Kernel.File.Handle {
    /// The operation a handle error occurred in. Mirrors
    /// `ISO_9945.Kernel.File.Handle.Operation`.
    public enum Operation: Swift.String, Sendable {
        case read
        case write
        case seek
        case sync
    }
}
