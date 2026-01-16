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
@_spi(Syscall) public import Kernel_Primitives
public import WinSDK

// MARK: - Socket Connect

extension Windows.Kernel.Socket {
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
        _ socket: Kernel.Socket.Descriptor,
        address: UnsafePointer<sockaddr>,
        addressLength: Int32
    ) throws(Error) {
        let result = WinSDK.connect(SOCKET(socket.rawValue), address, addressLength)
        guard result == 0 else {
            throw .connect(captureLastSocketError())
        }
    }

    /// Connects a socket to an IPv4 address.
    ///
    /// - Parameters:
    ///   - socket: The socket to connect.
    ///   - address: The IPv4 address structure.
    /// - Throws: `Error.connect` on failure.
    public static func connect(
        _ socket: Kernel.Socket.Descriptor,
        address: sockaddr_in
    ) throws(Error) {
        var addr = address
        try withUnsafePointer(to: &addr) { ptr in
            try ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { addrPtr in
                try connect(socket, address: addrPtr, addressLength: Int32(MemoryLayout<sockaddr_in>.size))
            }
        }
    }

    /// Connects a socket to an IPv6 address.
    ///
    /// - Parameters:
    ///   - socket: The socket to connect.
    ///   - address: The IPv6 address structure.
    /// - Throws: `Error.connect` on failure.
    public static func connect(
        _ socket: Kernel.Socket.Descriptor,
        address: sockaddr_in6
    ) throws(Error) {
        var addr = address
        try withUnsafePointer(to: &addr) { ptr in
            try ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { addrPtr in
                try connect(socket, address: addrPtr, addressLength: Int32(MemoryLayout<sockaddr_in6>.size))
            }
        }
    }
}

#endif
