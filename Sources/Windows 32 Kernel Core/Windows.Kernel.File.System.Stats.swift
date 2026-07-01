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

extension Windows.`32`.Kernel.File.System {
    /// Filesystem statistics.
    ///
    /// Namespace for filesystem-statistics error types. The `Stats` value type
    /// (block counts, filesystem identifier, type name, etc.) and its syscall
    /// implementation live in the platform package `swift-windows-primitives`.
    public enum Stats: Sendable {}
}
