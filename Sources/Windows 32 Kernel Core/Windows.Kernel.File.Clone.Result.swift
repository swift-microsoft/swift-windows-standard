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
    /// How the clone was performed. Mirrors `ISO_9945.Kernel.File.Clone.Result`.
    public enum Result: Sendable, Equatable {
        /// The file was reflinked (shared extents).
        case reflinked

        /// The file data was copied.
        case copied
    }
}
