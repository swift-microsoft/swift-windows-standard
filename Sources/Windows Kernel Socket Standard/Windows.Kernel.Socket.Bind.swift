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

// MARK: - Socket Bind

extension Windows.Kernel.Socket {
    /// Binds a socket to a local address.
    ///
    /// Associates the socket with a local address and port. Required for
    /// server sockets before calling `listen()`.
    ///
    /// - Parameters:
    ///   - socket: The socket to bind.
    ///   - address: Pointer to the address structure.
    ///   - addressLength: Size of the address structure.
    /// - Throws: `Error.bind` on failure.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var addr = sockaddr_in()
    /// addr.sin_family = ADDRESS_FAMILY(AF_INET)
    /// addr.sin_port = htons(8080)
    /// addr.sin_addr.s_addr = INADDR_ANY
    ///
    /// try withUnsafePointer(to: &addr) { ptr in
    ///     try ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { addrPtr in
    ///         try Windows.Kernel.Socket.bind(
    ///             socket,
    ///             address: addrPtr,
    ///             addressLength: Int32(MemoryLayout<sockaddr_in>.size)
    ///         )
    ///     }
    /// }
    /// ```
    public static func bind(
        _ socket: borrowing Kernel.Socket.Descriptor,
        address: UnsafePointer<sockaddr>,
        addressLength: Int32
    ) throws(Error) {
        try bind(socket._rawValue, address: address, addressLength: addressLength)
    }

    /// Binds a SOCKET bit pattern to a local address.
    ///
    /// Spec-literal raw `bind`. The typed L2 convenience
    /// (`bind(_:address:addressLength:)` taking
    /// `borrowing Kernel.Socket.Descriptor`) delegates to this raw SPI
    /// internally via `socket._rawValue`.
    ///
    /// - Parameters:
    ///   - socket: SOCKET bit pattern.
    ///   - address: Pointer to the address structure.
    ///   - addressLength: Size of the address structure.
    /// - Throws: `Error.bind` on failure.
    @_spi(Syscall)
    public static func bind(
        _ socket: UInt,
        address: UnsafePointer<sockaddr>,
        addressLength: Int32
    ) throws(Error) {
        let result = WinSDK.bind(SOCKET(socket), address, addressLength)
        guard result == 0 else {
            throw .bind(captureLastSocketError())
        }
    }
}

// MARK: - Address Helpers

extension Windows.Kernel.Socket {
    /// Converts a port number to network byte order.
    @inlinable
    public static func htons(_ port: UInt16) -> UInt16 {
        port.bigEndian
    }

    /// Converts a port number from network byte order.
    @inlinable
    public static func ntohs(_ port: UInt16) -> UInt16 {
        UInt16(bigEndian: port)
    }

    /// Converts a 32-bit value to network byte order.
    @inlinable
    public static func htonl(_ value: UInt32) -> UInt32 {
        value.bigEndian
    }

    /// Converts a 32-bit value from network byte order.
    @inlinable
    public static func ntohl(_ value: UInt32) -> UInt32 {
        UInt32(bigEndian: value)
    }
}

#endif
