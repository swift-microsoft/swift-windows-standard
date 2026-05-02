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
// `ISO_9945.Kernel.File.Size` shape at the Windows L2 spec layer per
// [PLAT-ARCH-005] L2-canonical-where-spec-layer-exists + [PLAT-ARCH-008k]
// Spec/Policy Namespace Split. Storage backing is a typealias to the L1
// `Magnitude<Space>.Value<Int64>` per principal Q3 disposition.

#if os(Windows)

public import Binary_Primitives_Core
public import Dimension_Primitives
public import Memory_Primitives

extension Windows.`32`.Kernel.File {
    /// File size as a non-directional magnitude.
    ///
    /// A type-safe wrapper for file sizes and byte counts. Uses the Dimension module
    /// to provide proper dimensional arithmetic with `Offset` and `Delta`:
    /// - `Offset + Size = Offset` (translate position by size)
    /// - `Size + Size = Size` (combine sizes)
    /// - `Size - Size = Size` (difference of sizes)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let size: Windows.`32`.Kernel.File.Size = 4096
    /// let offset: Windows.`32`.Kernel.File.Offset = 1000
    /// let newOffset = offset + size  // File.Offset
    ///
    /// // Create from pages
    /// let pageSize = Windows.`32`.Kernel.File.Size(pages: 4, pageSize: 4096)
    /// ```
    public typealias Size = Magnitude<Space>.Value<Int64>
}

// MARK: - Size Constants

extension Windows.`32`.Kernel.File.Size {
    /// One kilobyte (1024 bytes).
    public static let kilobyte: Self = Self(1024)

    /// One megabyte (1024 * 1024 bytes).
    public static let megabyte: Self = Self(1024 * 1024)

    /// One gigabyte (1024 * 1024 * 1024 bytes).
    public static let gigabyte: Self = Self(1024 * 1024 * 1024)

    /// One system page.
    ///
    /// - Parameter pageSize: The system page size in bytes.
    ///   Use `Windows.`32`.Kernel.System.pageSize`.
    @inlinable
    public static func page(size pageSize: UInt) -> Self {
        Self(Int64(pageSize))
    }
}

// MARK: - Convenience Initializers

extension Windows.`32`.Kernel.File.Size {
    /// Creates a file size from a number of pages.
    ///
    /// - Parameters:
    ///   - pages: Number of pages.
    ///   - pageSize: The system page size in bytes.
    @inlinable
    public init(pages: Int, pageSize: UInt) {
        self.init(Int64(pages) * Int64(pageSize))
    }

    /// Creates a file size from an Int value.
    @inlinable
    public init(_ value: Int) {
        self.init(Int64(value))
    }

    /// Creates a file size from a UInt64 value.
    @inlinable
    public init(_ value: UInt64) {
        self.init(Int64(bitPattern: value))
    }

    /// Creates a file size from a file delta.
    ///
    /// Use this when converting a non-negative displacement to a magnitude.
    ///
    /// - Parameter delta: The file delta (must be non-negative).
    /// - Precondition: `delta` must be non-negative.
    @inlinable
    public init(_ delta: Windows.`32`.Kernel.File.Delta) {
        precondition(delta.rawValue >= 0, "Delta must be non-negative to convert to Size")
        self.init(delta.rawValue)
    }
}

// MARK: - Queries

extension Windows.`32`.Kernel.File.Size {
    /// Whether this size is zero.
    @inlinable
    public var isZero: Bool {
        rawValue == 0
    }

    /// Whether this size is positive (greater than zero).
    @inlinable
    public var isPositive: Bool {
        rawValue > 0
    }
}

// MARK: - Alignment

extension Windows.`32`.Kernel.File.Size {
    /// Whether this size is aligned to the given alignment.
    ///
    /// - Parameter alignment: The alignment boundary (power of 2).
    /// - Returns: `true` if this size is a multiple of the alignment.
    public func isAligned(to alignment: Memory.Alignment) -> Bool {
        let mask: Int64 = alignment.mask()
        return rawValue & mask == 0
    }

    /// Rounds this size down to the nearest alignment boundary.
    ///
    /// - Parameter alignment: The alignment boundary (power of 2).
    /// - Returns: The largest aligned size ≤ `self`.
    public func alignedDown(to alignment: Memory.Alignment) -> Self {
        let mask: Int64 = alignment.mask()
        return Self(rawValue & ~mask)
    }

    /// Rounds this size up to the nearest alignment boundary.
    ///
    /// - Parameter alignment: The alignment boundary (power of 2).
    /// - Returns: The smallest aligned size ≥ `self`.
    public func alignedUp(to alignment: Memory.Alignment) -> Self {
        let mask: Int64 = alignment.mask()
        return Self((rawValue &+ mask) & ~mask)
    }
}

// MARK: - Int from File.Size

extension Int {
    /// Creates an Int from a file size for syscall boundaries.
    ///
    /// - Parameter size: The file size.
    @inlinable
    public init(_ size: Windows.`32`.Kernel.File.Size) {
        self = Int(size.rawValue)
    }
}

#endif
