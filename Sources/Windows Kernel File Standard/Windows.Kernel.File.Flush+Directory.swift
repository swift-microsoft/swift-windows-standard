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
    /// Persists directory entries (rename visibility) to storage.
    ///
    /// Single entry point for "directory sync" semantics. Consumer code can
    /// write a single unconditional call site instead of a `#if os(Windows)`
    /// branch separating the POSIX `open + fsync + close` recipe from a
    /// Windows no-op.
    ///
    /// Cross-platform contract:
    /// - **POSIX**: opens the directory `O_RDONLY`, calls `fsync`, then
    ///   relies on `Kernel.Descriptor`'s `deinit` to close. The directory is
    ///   opened with `O_CLOEXEC` so it does not leak across `exec`.
    /// - **Windows**: documented no-op. Windows does not expose a
    ///   directory-fsync primitive; rename durability is provided by the
    ///   rename itself plus subsequent `FlushFileBuffers` on affected files.
    ///
    /// The Windows branch deliberately does nothing and never throws. The
    /// signature matches the POSIX branch so consumers can call this
    /// unconditionally as part of a durable-rename recipe; the no-op is
    /// the documented Windows semantic, not a missing implementation.
    ///
    /// - Parameter path: The directory path (borrowed view; unused on Windows).
    /// - Throws: never on Windows.
    @inlinable
    public static func directory(path: borrowing Kernel.Path.View) throws(Error) {
        // Windows has no directory-fsync primitive. Rename durability is
        // provided by the rename itself + FlushFileBuffers on affected files.
        // See header documentation for cross-platform contract.
        _ = path
    }
}

#endif
