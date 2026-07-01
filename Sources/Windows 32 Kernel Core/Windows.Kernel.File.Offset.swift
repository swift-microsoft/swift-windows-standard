// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Tier 5-Windows-FOS+Affinity-Combined Phase 2 (2026-05-02): mirrors the
// `ISO_9945.Kernel.File.Offset` shape at the Windows L2 spec layer per
// [PLAT-ARCH-005] L2-canonical-where-spec-layer-exists + [PLAT-ARCH-008k]
// Spec/Policy Namespace Split. Storage backing is a typealias to the L1
// `Coordinate.X<Space>.Value<Int64>` per principal Q3 disposition (POSIX-
// mirror; NOT a canonical struct).

#if os(Windows)

public import Dimension_Primitives

extension Windows.`32`.Kernel.File {
    /// File offset for positional I/O operations.
    ///
    /// A type-safe coordinate for file positions. Provides dimensional arithmetic:
    /// - `Offset - Offset = Delta` (difference between positions)
    /// - `Offset + Delta = Offset` (translate position)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let start: Windows.`32`.Kernel.File.Offset = 1000
    /// let end: Windows.`32`.Kernel.File.Offset = 5000
    /// let distance = end - start  // Delta (4000 bytes)
    /// let next = start + distance // Offset (5000)
    /// ```
    public typealias Offset = Coordinate.X<Space>.Value<Int64>

    /// Signed displacement between file offsets.
    ///
    /// The result of subtracting two offsets. Can be positive or negative.
    public typealias Delta = Displacement.X<Space>.Value<Int64>
}

// MARK: - Offset Constants

extension Windows.`32`.Kernel.File.Offset {
    /// Maximum offset (end of file marker for lock ranges).
    public static let max = Self(Int64.max)
}

// MARK: - Convenience Initializers

extension Windows.`32`.Kernel.File.Offset {
    /// Creates a file offset from an Int value.
    @inlinable
    public init(_ value: Int) {
        self.init(Int64(value))
    }
}

#endif
