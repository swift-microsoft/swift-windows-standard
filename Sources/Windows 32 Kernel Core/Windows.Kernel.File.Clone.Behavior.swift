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

extension Windows.`32`.Kernel.File.Clone {
    /// The cloning behavior policy. Mirrors `ISO_9945.Kernel.File.Clone.Behavior`.
    public enum Behavior: Sendable, Equatable {
        /// Reflink only; fail if unsupported.
        case reflinkOrFail

        /// Reflink if available, otherwise fall back to a data copy.
        case reflinkOrCopy

        /// Always copy the data.
        case copyOnly
    }
}
