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

public import Path_Primitives

extension Windows.`32`.Kernel.File.Direct {
    /// Alignment requirements for Direct I/O. Mirrors
    /// `ISO_9945.Kernel.File.Direct.Requirements`.
    public enum Requirements: Sendable, Equatable {
        /// The requirements were determined.
        case known(Alignment)

        /// The requirements could not be determined.
        case unknown(reason: Reason)
    }
}

// MARK: - Portable Initialization

extension Windows.`32`.Kernel.File.Direct.Requirements {
    /// Discovers Direct I/O requirements for a path.
    ///
    /// Windows: strict sector-size discovery (GetDiskFreeSpaceW per volume)
    /// is not wired at this layer yet; report undetermined so `Mode.auto`
    /// resolves to buffered and strict `.direct` requests fail loudly
    /// rather than misalign.
    public init(_ path: borrowing Path.Borrowed) {
        self = .unknown(reason: .sectorSizeUndetermined)
    }
}
