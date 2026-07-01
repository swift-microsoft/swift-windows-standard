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

extension Windows.`32`.Kernel {
    /// Windows socket (Winsock2) operations.
    ///
    /// Provides low-level Winsock2 API wrappers for socket operations. For
    /// higher-level networking, see swift-networking which builds on these
    /// primitives.
    ///
    /// ## Initialization
    ///
    /// Unlike POSIX, Winsock2 requires explicit initialization via `WSAStartup`
    /// before any socket operations. Call `startup()` before using sockets and
    /// `cleanup()` when done.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.Socket`)
    /// - Windows: `swift-windows-standard` (`Windows.32.Kernel.Socket`)
    public enum Socket: Sendable {}
}
