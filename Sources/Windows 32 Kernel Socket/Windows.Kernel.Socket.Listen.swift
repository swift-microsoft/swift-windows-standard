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
public import Error_Primitives
public import WinSDK

// MARK: - Socket Listen

extension Windows.`32`.Kernel.Socket {
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
    /// let sock = try Windows.`32`.Kernel.Socket.create(family: .inet, type: .stream)
    /// // ... bind socket ...
    /// try Windows.`32`.Kernel.Socket.listen(sock, backlog: .default)
    /// ```
    public static func listen(
        _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
        backlog: Windows.`32`.Kernel.Socket.Backlog
    ) throws(Error) {
        try listen(socket._rawValue, backlog: backlog)
    }

    /// Places a SOCKET bit pattern in listening state.
    ///
    /// Spec-literal raw `listen`. The typed L2 convenience
    /// (`listen(_:backlog:)` taking `borrowing Windows.`32`.Kernel.Socket.Descriptor`)
    /// delegates to this raw SPI internally via `socket._rawValue`.
    ///
    /// - Parameters:
    ///   - socket: SOCKET bit pattern.
    ///   - backlog: Maximum length of the pending connections queue.
    /// - Throws: `Error.listen` on failure.
        package static func listen(
        _ socket: UInt,
        backlog: Windows.`32`.Kernel.Socket.Backlog
    ) throws(Error) {
        let result = WinSDK.listen(SOCKET(socket), backlog.rawValue)
        guard result == 0 else {
            throw .platform(Error_Primitives.Error(code: captureLastSocketError()))
        }
    }
}

// MARK: - Backlog Platform Values

extension Windows.`32`.Kernel.Socket.Backlog {
    /// Maximum backlog value on Windows.
    ///
    /// `SOMAXCONN` is typically 0x7FFFFFFF on modern Windows.
    public static var max: Windows.`32`.Kernel.Socket.Backlog {
        Windows.`32`.Kernel.Socket.Backlog(rawValue: SOMAXCONN)
    }
}

#endif
