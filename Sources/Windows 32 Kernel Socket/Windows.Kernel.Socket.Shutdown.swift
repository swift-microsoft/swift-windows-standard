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

// MARK: - Socket Shutdown

extension Windows.`32`.Kernel.Socket {
    /// Shuts down part of a full-duplex connection.
    ///
    /// Disables sends, receives, or both on a socket. This does not close
    /// the socket; use `close()` to release the socket descriptor.
    ///
    /// - Parameters:
    ///   - socket: The socket to shut down.
    ///   - how: Which operations to disable.
    /// - Throws: `Error.shutdown` on failure.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Signal that we're done sending (half-close)
    /// try Windows.`32`.Kernel.Socket.shutdown(sock, how: .write)
    ///
    /// // Can still receive data until the peer closes
    /// let bytes = try Windows.`32`.Kernel.Socket.receive(sock, buffer: &buf)
    ///
    /// // Now fully close the socket
    /// try Windows.`32`.Kernel.Socket.close(sock)
    /// ```
    public static func shutdown(
        _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
        how: Windows.`32`.Kernel.Socket.Shutdown.How
    ) throws(Windows.`32`.Kernel.Socket.Shutdown.Error) {
        try shutdown(socket._rawValue, how: how)
    }

    /// Shuts down part of a full-duplex connection on a SOCKET bit pattern.
    ///
    /// Spec-literal raw `shutdown`. The typed L2 convenience
    /// (`shutdown(_:how:)` taking `borrowing Windows.`32`.Kernel.Socket.Descriptor`)
    /// delegates to this raw SPI internally via `socket._rawValue`.
    ///
    /// - Parameters:
    ///   - socket: SOCKET bit pattern.
    ///   - how: Which operations to disable.
    /// - Throws: `Error.shutdown` on failure.
        package static func shutdown(
        _ socket: UInt,
        how: Windows.`32`.Kernel.Socket.Shutdown.How
    ) throws(Windows.`32`.Kernel.Socket.Shutdown.Error) {
        let sdHow: Int32
        switch how {
        case .read:
            sdHow = SD_RECEIVE
        case .write:
            sdHow = SD_SEND
        case .both:
            sdHow = SD_BOTH
        }

        let result = WinSDK.shutdown(SOCKET(socket), sdHow)
        guard result == 0 else {
            throw .platform(Error_Primitives.Error(code: captureLastSocketError()))
        }
    }
}

// MARK: - Windows-specific Shutdown Values

extension Windows.`32`.Kernel.Socket.Shutdown.How {
    /// Windows shutdown constant for read.
    public static var sdReceive: Int32 { SD_RECEIVE }

    /// Windows shutdown constant for write.
    public static var sdSend: Int32 { SD_SEND }

    /// Windows shutdown constant for both.
    public static var sdBoth: Int32 { SD_BOTH }
}

#endif
