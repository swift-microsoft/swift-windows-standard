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
    /// Link types.
    public enum Link: Sendable, Equatable, Hashable {
        /// Symbolic link.
        case symbolic

        /// Junction or mount point.
        ///
        /// Junctions and mount points are reparse points with
        /// `IO_REPARSE_TAG_MOUNT_POINT`. They behave like directory symlinks
        /// but have different semantics (junctions are always absolute paths).
        case junction
    }
}
