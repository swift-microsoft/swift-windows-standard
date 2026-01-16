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

// MARK: - Socket Receive

extension Windows.Kernel.Socket {
    /// Receive flags.
    public struct ReceiveFlags: OptionSet, Sendable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Peek at incoming data without removing it from the queue.
        public static let peek = ReceiveFlags(rawValue: MSG_PEEK)

        /// Receive out-of-band data.
        public static let outOfBand = ReceiveFlags(rawValue: MSG_OOB)

        /// Block until the full amount is received.
        public static let waitAll = ReceiveFlags(rawValue: MSG_WAITALL)

        /// No flags.
        public static let none = ReceiveFlags(rawValue: 0)
    }

    /// Receives data from a connected socket.
    ///
    /// - Parameters:
    ///   - socket: The connected socket.
    ///   - buffer: Buffer to receive data into.
    ///   - length: Maximum number of bytes to receive.
    ///   - flags: Receive flags.
    /// - Returns: Number of bytes received, or 0 if the connection was closed.
    /// - Throws: `Error.receive` on failure.
    ///
    /// ## Return Values
    ///
    /// - Positive: Number of bytes received.
    /// - Zero: Connection closed gracefully (EOF).
    /// - Error: Connection error or socket error.
    public static func receive(
        _ socket: Kernel.Socket.Descriptor,
        buffer: UnsafeMutableRawPointer,
        length: Int,
        flags: ReceiveFlags = .none
    ) throws(Error) -> Int {
        let result = recv(
            SOCKET(socket.rawValue),
            buffer.assumingMemoryBound(to: CChar.self),
            Int32(length),
            flags.rawValue
        )
        guard result != SOCKET_ERROR else {
            throw .receive(captureLastSocketError())
        }
        return Int(result)
    }

    /// Receives data from a connected socket into a buffer.
    ///
    /// - Parameters:
    ///   - socket: The connected socket.
    ///   - buffer: The buffer to receive data into.
    ///   - flags: Receive flags.
    /// - Returns: Number of bytes received.
    /// - Throws: `Error.receive` on failure.
    public static func receive(
        _ socket: Kernel.Socket.Descriptor,
        buffer: UnsafeMutableBufferPointer<UInt8>,
        flags: ReceiveFlags = .none
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }
        return try receive(socket, buffer: baseAddress, length: buffer.count, flags: flags)
    }

    /// Receives data and retrieves the source address.
    ///
    /// Used for connectionless (datagram) sockets to receive data and
    /// determine who sent it.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - buffer: Buffer to receive data into.
    ///   - length: Maximum number of bytes to receive.
    ///   - flags: Receive flags.
    ///   - srcAddr: Pointer to receive the source address.
    ///   - srcAddrLength: On input, size of the address buffer.
    ///                    On output, actual size of the returned address.
    /// - Returns: Number of bytes received.
    /// - Throws: `Error.receive` on failure.
    public static func receiveFrom(
        _ socket: Kernel.Socket.Descriptor,
        buffer: UnsafeMutableRawPointer,
        length: Int,
        flags: ReceiveFlags = .none,
        srcAddr: UnsafeMutablePointer<sockaddr>,
        srcAddrLength: UnsafeMutablePointer<Int32>
    ) throws(Error) -> Int {
        let result = recvfrom(
            SOCKET(socket.rawValue),
            buffer.assumingMemoryBound(to: CChar.self),
            Int32(length),
            flags.rawValue,
            srcAddr,
            srcAddrLength
        )
        guard result != SOCKET_ERROR else {
            throw .receive(captureLastSocketError())
        }
        return Int(result)
    }

    /// Receives data from an IPv4 source.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - buffer: The buffer to receive data into.
    ///   - flags: Receive flags.
    /// - Returns: Number of bytes received and the source address.
    /// - Throws: `Error.receive` on failure.
    public static func receiveFromIPv4(
        _ socket: Kernel.Socket.Descriptor,
        buffer: UnsafeMutableBufferPointer<UInt8>,
        flags: ReceiveFlags = .none
    ) throws(Error) -> (bytesReceived: Int, sourceAddress: sockaddr_in) {
        guard let baseAddress = buffer.baseAddress else {
            return (0, sockaddr_in())
        }

        var srcAddr = sockaddr_in()
        var addrLen = Int32(MemoryLayout<sockaddr_in>.size)

        let bytesReceived = try withUnsafeMutablePointer(to: &srcAddr) { ptr in
            try ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { addrPtr in
                try receiveFrom(
                    socket,
                    buffer: baseAddress,
                    length: buffer.count,
                    flags: flags,
                    srcAddr: addrPtr,
                    srcAddrLength: &addrLen
                )
            }
        }

        return (bytesReceived, srcAddr)
    }

    /// Receives data from an IPv6 source.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - buffer: The buffer to receive data into.
    ///   - flags: Receive flags.
    /// - Returns: Number of bytes received and the source address.
    /// - Throws: `Error.receive` on failure.
    public static func receiveFromIPv6(
        _ socket: Kernel.Socket.Descriptor,
        buffer: UnsafeMutableBufferPointer<UInt8>,
        flags: ReceiveFlags = .none
    ) throws(Error) -> (bytesReceived: Int, sourceAddress: sockaddr_in6) {
        guard let baseAddress = buffer.baseAddress else {
            return (0, sockaddr_in6())
        }

        var srcAddr = sockaddr_in6()
        var addrLen = Int32(MemoryLayout<sockaddr_in6>.size)

        let bytesReceived = try withUnsafeMutablePointer(to: &srcAddr) { ptr in
            try ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { addrPtr in
                try receiveFrom(
                    socket,
                    buffer: baseAddress,
                    length: buffer.count,
                    flags: flags,
                    srcAddr: addrPtr,
                    srcAddrLength: &addrLen
                )
            }
        }

        return (bytesReceived, srcAddr)
    }
}

#endif
