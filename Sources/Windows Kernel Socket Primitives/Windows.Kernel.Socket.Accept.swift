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
        _ socket: borrowing Kernel.Socket.Descriptor
    ) throws(Error) -> Kernel.Socket.Descriptor {
        let clientSocket = WinSDK.accept(SOCKET(socket._rawValue), nil, nil)
        guard clientSocket != INVALID_SOCKET else {
            throw .accept(captureLastSocketError())
        }
        return Kernel.Socket.Descriptor(_rawValue: UInt(clientSocket))
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
        _ socket: borrowing Kernel.Socket.Descriptor,
        address: UnsafeMutablePointer<sockaddr>,
        addressLength: UnsafeMutablePointer<Int32>
    ) throws(Error) -> Kernel.Socket.Descriptor {
        let clientSocket = WinSDK.accept(SOCKET(socket._rawValue), address, addressLength)
        guard clientSocket != INVALID_SOCKET else {
            throw .accept(captureLastSocketError())
        }
        return Kernel.Socket.Descriptor(_rawValue: UInt(clientSocket))
    }
}

#endif
