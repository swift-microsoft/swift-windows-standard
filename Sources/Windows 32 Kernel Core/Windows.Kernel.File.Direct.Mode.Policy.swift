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

extension Windows.`32`.Kernel.File.Direct.Mode {
    /// Policy for ``Mode/auto(policy:)`` resolution. Mirrors
    /// `ISO_9945.Kernel.File.Direct.Mode.Policy`.
    public enum Policy: Sendable, Equatable {
        /// Fall back to buffered I/O when direct I/O is unavailable.
        case fallbackToBuffered

        /// Error when direct I/O requirements cannot be met.
        case errorOnViolation
    }
}
