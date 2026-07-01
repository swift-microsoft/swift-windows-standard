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

extension Windows.`32`.Kernel.File {
    /// File flush (synchronization) operations.
    ///
    /// Provides fsync functionality for durably persisting file data to storage.
    ///
    /// Wraps POSIX `fsync()` / Windows `FlushFileBuffers()`.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.File.Flush`)
    /// - Windows: `swift-windows-standard` (`Windows.Kernel.File.Flush`)
    public enum Flush: Sendable {}
}
