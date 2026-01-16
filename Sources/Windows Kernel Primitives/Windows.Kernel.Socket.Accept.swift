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

// MARK: - Socket Accept

extension Windows.Kernel.Socket {
    /// Accepts an incoming connection on a listening socket.
    ///
    /// Extracts the first connection request from the queue of pending
    /// connections and creates a new socket for that connection.
    ///
    /// - Parameter socket: The listening socket.
    /// - Returns: The new connected socket descriptor.
    /// - Throws: `Error.accept` on failure.
    ///
    /// ## Blocking Behavior
    ///
    /// By default, this call blocks until a connection is available.
    /// For non-blocking sockets, it returns immediately with
    /// `WSAEWOULDBLOCK` if no connections are pending.
    public static func accept(
        _ socket: Kernel.Socket.Descriptor
    ) throws(Error) -> Kernel.Socket.Descriptor {
        let clientSocket = WinSDK.accept(SOCKET(socket.rawValue), nil, nil)
        guard clientSocket != INVALID_SOCKET else {
            throw .accept(captureLastSocketError())
        }
        return Kernel.Socket.Descriptor(rawValue: UInt64(bitPattern: Int64(clientSocket)))
    }

    /// Accepts an incoming connection and retrieves the client address.
    ///
    /// - Parameters:
    ///   - socket: The listening socket.
    ///   - address: Pointer to receive the client address.
    ///   - addressLength: On input, the size of the address buffer.
    ///                    On output, the actual size of the returned address.
    /// - Returns: The new connected socket descriptor.
    /// - Throws: `Error.accept` on failure.
    public static func accept(
        _ socket: Kernel.Socket.Descriptor,
        address: UnsafeMutablePointer<sockaddr>,
        addressLength: UnsafeMutablePointer<Int32>
    ) throws(Error) -> Kernel.Socket.Descriptor {
        let clientSocket = WinSDK.accept(SOCKET(socket.rawValue), address, addressLength)
        guard clientSocket != INVALID_SOCKET else {
            throw .accept(captureLastSocketError())
        }
        return Kernel.Socket.Descriptor(rawValue: UInt64(bitPattern: Int64(clientSocket)))
    }

    /// Result of an accept operation with client address.
    public struct AcceptResult {
        /// The connected client socket.
        public let socket: Kernel.Socket.Descriptor

        /// The client's IPv4 address (if applicable).
        public let addressIPv4: sockaddr_in?

        /// The client's IPv6 address (if applicable).
        public let addressIPv6: sockaddr_in6?
    }

    /// Accepts an incoming IPv4 connection and retrieves the client address.
    ///
    /// - Parameter socket: The listening socket.
    /// - Returns: The new socket and client address.
    /// - Throws: `Error.accept` on failure.
    public static func acceptIPv4(
        _ socket: Kernel.Socket.Descriptor
    ) throws(Error) -> (socket: Kernel.Socket.Descriptor, address: sockaddr_in) {
        var clientAddr = sockaddr_in()
        var addrLen = Int32(MemoryLayout<sockaddr_in>.size)

        let clientSocket = withUnsafeMutablePointer(to: &clientAddr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { addrPtr in
                WinSDK.accept(SOCKET(socket.rawValue), addrPtr, &addrLen)
            }
        }

        guard clientSocket != INVALID_SOCKET else {
            throw .accept(captureLastSocketError())
        }

        return (
            socket: Kernel.Socket.Descriptor(rawValue: UInt64(bitPattern: Int64(clientSocket))),
            address: clientAddr
        )
    }

    /// Accepts an incoming IPv6 connection and retrieves the client address.
    ///
    /// - Parameter socket: The listening socket.
    /// - Returns: The new socket and client address.
    /// - Throws: `Error.accept` on failure.
    public static func acceptIPv6(
        _ socket: Kernel.Socket.Descriptor
    ) throws(Error) -> (socket: Kernel.Socket.Descriptor, address: sockaddr_in6) {
        var clientAddr = sockaddr_in6()
        var addrLen = Int32(MemoryLayout<sockaddr_in6>.size)

        let clientSocket = withUnsafeMutablePointer(to: &clientAddr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { addrPtr in
                WinSDK.accept(SOCKET(socket.rawValue), addrPtr, &addrLen)
            }
        }

        guard clientSocket != INVALID_SOCKET else {
            throw .accept(captureLastSocketError())
        }

        return (
            socket: Kernel.Socket.Descriptor(rawValue: UInt64(bitPattern: Int64(clientSocket))),
            address: clientAddr
        )
    }
}

#endif
