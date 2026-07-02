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
    /// The resolved effective mode. Mirrors
    /// `ISO_9945.Kernel.File.Direct.Mode.Resolved`.
    public enum Resolved: Sendable, Equatable {
        case direct
        case uncached
        case buffered
    }
}
