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

extension Windows.`32`.Kernel.File.Stats.Kind {
    /// Device types.
    public enum Device: Sendable, Equatable, Hashable {
        /// Block device.
        case block

        /// Character device.
        case character
    }
}
