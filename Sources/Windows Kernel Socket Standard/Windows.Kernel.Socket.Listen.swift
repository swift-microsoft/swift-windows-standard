// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
@_spi(Syscall) public import Error_Primitives
@_spi(Syscall) public import Kernel_Socket_Primitives
public import WinSDK

// MARK: - Socket Listen

extension Windows.Kernel.Socket {
    /// Places a socket in listening state.
    ///
    /// Marks the socket as a passive socket that will accept incoming
    /// connections using `accept()`.
    ///
    /// - Parameters:
    ///   - socket: The socket to listen on.
    ///   - backlog: Maximum length of the pending connections queue.
    /// - Throws: `Error.listen` on failure.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream)
    /// // ... bind socket ...
    /// try Windows.Kernel.Socket.listen(sock, backlog: .default)
    /// ```
    public static func listen(
        _ socket: borrowing Kernel.Socket.Descriptor,
        backlog: Kernel.Socket.Backlog
    ) throws(Error) {
        try listen(socket._rawValue, backlog: backlog)
    }

    /// Places a SOCKET bit pattern in listening state.
    ///
    /// Spec-literal raw `listen`. The typed L2 convenience
    /// (`listen(_:backlog:)` taking `borrowing Kernel.Socket.Descriptor`)
    /// delegates to this raw SPI internally via `socket._rawValue`.
    ///
    /// - Parameters:
    ///   - socket: SOCKET bit pattern.
    ///   - backlog: Maximum length of the pending connections queue.
    /// - Throws: `Error.listen` on failure.
    @_spi(Syscall)
    public static func listen(
        _ socket: UInt,
        backlog: Kernel.Socket.Backlog
    ) throws(Error) {
        let result = WinSDK.listen(SOCKET(socket), backlog.rawValue)
        guard result == 0 else {
            throw .listen(captureLastSocketError())
        }
    }
}

// MARK: - Backlog Platform Values

extension Kernel.Socket.Backlog {
    /// Maximum backlog value on Windows.
    ///
    /// `SOMAXCONN` is typically 0x7FFFFFFF on modern Windows.
    public static var max: Kernel.Socket.Backlog {
        Kernel.Socket.Backlog(rawValue: SOMAXCONN)
    }
}

#endif
