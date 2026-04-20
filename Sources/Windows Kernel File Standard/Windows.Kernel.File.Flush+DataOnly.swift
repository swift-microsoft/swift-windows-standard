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

#if os(Windows)

extension Kernel.File.Flush {
    /// Synchronizes file data to storage with the best available platform semantic.
    ///
    /// Single entry point for "data-only sync" semantics. Consumer code can write
    /// a single unconditional call site instead of a per-platform `#if` between
    /// `data(_:)` (Linux), `barrier(_:)` (Darwin), and `flush(_:)` (fallback).
    ///
    /// Cross-platform contract:
    /// - **Linux**: ``ISO_9945/Kernel/File/Flush/data(_:)`` (`fdatasync(2)`).
    /// - **Darwin**: ``ISO_9945/Kernel/File/Flush/barrier(_:)``
    ///   (`fcntl(F_BARRIERFSYNC)`) — closest available "data-only-ish" semantic.
    /// - **Other POSIX** (OpenBSD, etc.): falls back to
    ///   ``ISO_9945/Kernel/File/Flush/flush(_:)`` (`fsync(2)`).
    /// - **Windows**: ``Windows/Kernel/File/Flush/flush(_:)``
    ///   (`FlushFileBuffers`) — Windows has no data-only distinction.
    ///
    /// On Windows the underlying `FlushFileBuffers` flushes both data and
    /// metadata. The "data-only" name names the unifier's cross-platform
    /// intent; on Windows it is implemented as a strictly-stronger full
    /// flush, never a weaker partial flush.
    ///
    /// - Parameter descriptor: The file descriptor to flush.
    /// - Throws: ``Kernel/File/Flush/Error`` on failure.
    @inlinable
    public static func dataOnly(_ descriptor: Kernel.Descriptor) throws(Error) {
        try Windows.Kernel.File.Flush.flush(descriptor)
    }
}

#endif
