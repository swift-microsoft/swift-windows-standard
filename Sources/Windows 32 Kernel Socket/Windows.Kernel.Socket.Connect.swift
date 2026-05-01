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

// MARK: - Socket Connect

extension Windows.`32`.Kernel.Socket {
    /// Connects a socket to a remote address.
    ///
    /// Establishes a connection to a specified address. For stream sockets
    /// (TCP), this initiates the three-way handshake. For datagram sockets
    /// (UDP), this sets the default destination address.
    ///
    /// - Parameters:
    ///   - socket: The socket to connect.
    ///   - address: Pointer to the remote address.
    ///   - addressLength: Size of the address structure.
    /// - Throws: `Error.connect` on failure.
    ///
    /// ## Blocking Behavior
    ///
    /// For blocking sockets, this call blocks until the connection is
    /// established or fails. For non-blocking sockets, it returns
    /// immediately with `WSAEWOULDBLOCK` if the connection cannot be
    /// completed immediately.
    public static func connect(
        _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
        address: UnsafePointer<sockaddr>,
        addressLength: Int32
    ) throws(Error) {
        try connect(socket._rawValue, address: address, addressLength: addressLength)
    }

    /// Connects a SOCKET bit pattern to a remote address.
    ///
    /// Spec-literal raw `connect`. The typed L2 convenience
    /// (`connect(_:address:addressLength:)` taking
    /// `borrowing Windows.`32`.Kernel.Socket.Descriptor`) delegates to this raw SPI
    /// internally via `socket._rawValue`.
    ///
    /// - Parameters:
    ///   - socket: SOCKET bit pattern.
    ///   - address: Pointer to the remote address.
    ///   - addressLength: Size of the address structure.
    /// - Throws: `Error.connect` on failure.
        package static func connect(
        _ socket: UInt,
        address: UnsafePointer<sockaddr>,
        addressLength: Int32
    ) throws(Error) {
        let result = WinSDK.connect(SOCKET(socket), address, addressLength)
        guard result == 0 else {
            throw .connect(captureLastSocketError())
        }
    }
}

#endif
