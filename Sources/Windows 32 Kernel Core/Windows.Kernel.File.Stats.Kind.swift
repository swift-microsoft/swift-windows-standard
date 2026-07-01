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

extension Windows.`32`.Kernel.File.Stats {
    /// File type.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Stats.Kind`. The POSIX-only cases
    /// (`device`, `fifo`, `socket`) are retained for shape parity; Windows
    /// stats synthesis produces `regular`, `directory`, `link`, or `unknown`.
    public enum Kind: Sendable, Equatable, Hashable {
        /// Regular file.
        case regular

        /// Directory.
        case directory

        /// Symbolic link (reparse point).
        case link(Link)

        /// Device (block or character, POSIX only).
        case device(Device)

        /// Named pipe/FIFO (POSIX only).
        case fifo

        /// Socket (POSIX only).
        case socket

        /// Unknown or unsupported file type.
        case unknown
    }
}
