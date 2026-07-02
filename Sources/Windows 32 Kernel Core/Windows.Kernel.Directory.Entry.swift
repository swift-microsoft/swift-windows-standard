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

extension Windows.`32`.Kernel.Directory {
    /// A directory entry returned by iteration.
    ///
    /// Mirrors the Windows branch of `ISO_9945.Kernel.Directory.Entry`:
    /// preserves raw UTF-16 code units to support names that cannot be
    /// decoded to valid Unicode.
    public struct Entry: Sendable {
        /// Raw UTF-16 code units of the name, null-terminated.
        public let rawName: [UInt16]

        /// The inode number (POSIX only, nil on Windows).
        public let inode: Windows.`32`.Kernel.Inode?

        /// The type of entry, if known.
        public let type: Windows.`32`.Kernel.File.Stats.Kind?

        public init(
            rawName: [UInt16],
            inode: Windows.`32`.Kernel.Inode? = nil,
            type: Windows.`32`.Kernel.File.Stats.Kind? = nil
        ) {
            self.rawName = rawName
            self.inode = inode
            self.type = type
        }

        /// Returns true if this entry is "." or "..".
        ///
        /// `rawName` is null-terminated, so "." is `[0x002E, 0x0000]`
        /// and ".." is `[0x002E, 0x002E, 0x0000]`.
        public var isDotOrDotDot: Bool {
            rawName == [0x002E, 0x0000] || rawName == [0x002E, 0x002E, 0x0000]
        }

        #if os(Windows)
        /// The entry name as a `Path.Borrowed`. Zero allocation.
        ///
        /// `rawName` is null-terminated. This property borrows the array's
        /// heap buffer directly — the view cannot outlive `self`. Consumers
        /// reach content via `name.span` (Swift.Span<Path.Char>) or
        /// `name.pointer` (UnsafePointer<Path.Char>).
        ///
        /// Windows-only: relies on `Path.Char == UInt16`, which holds only
        /// on Windows; on other platforms the raw UTF-16 units remain
        /// accessible via ``rawName``.
        public var name: Path.Borrowed {
            @_lifetime(borrow self)
            borrowing get {
                let ptr = unsafe rawName.withUnsafeBufferPointer { $0.baseAddress! }
                let view = unsafe Path.Borrowed(ptr, count: rawName.count - 1)
                return unsafe _overrideLifetime(view, borrowing: self)
            }
        }
        #endif
    }
}
