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
    /// Namespace for Direct I/O operations (cache bypass).
    ///
    /// Direct I/O bypasses the operating system's page cache, allowing data to flow
    /// directly between user buffers and storage. This is useful for:
    /// - Database engines that manage their own caching
    /// - Large sequential I/O where cache pollution is undesirable
    /// - Applications requiring predictable latency
    ///
    /// ## Platform Semantics
    ///
    /// | Platform | Flag | Semantics | Alignment Required |
    /// |----------|------|-----------|-------------------|
    /// | Linux | `O_DIRECT` | Strict bypass | Yes (buffer, offset, length) |
    /// | Windows | `FILE_FLAG_NO_BUFFERING` | Strict bypass | Yes (sector-aligned) |
    /// | macOS | `fcntl(F_NOCACHE)` | Best-effort hint | No |
    ///
    /// **Important:** macOS `F_NOCACHE` is a *hint*, not a strict bypass. The kernel
    /// may still cache data. Use `.uncached` mode on macOS, not `.direct`.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.File.Direct`)
    /// - Windows: `swift-windows-standard` (`Windows.Kernel.File.Direct`)
    public enum Direct: Sendable {}
}
