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
public import WinSDK

// MARK: - Socket Send

extension Windows.Kernel.Socket {
    /// Send flags.
    public struct SendFlags: OptionSet, Sendable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Send out-of-band data.
        public static let outOfBand = SendFlags(rawValue: MSG_OOB)

        /// Bypass routing, send directly to interface.
        public static let dontRoute = SendFlags(rawValue: MSG_DONTROUTE)

        /// No flags.
        public static let none = SendFlags(rawValue: 0)
    }

    /// Sends data on a connected socket.
    ///
    /// - Parameters:
    ///   - socket: The connected socket.
    ///   - buffer: Pointer to the data to send.
    ///   - length: Number of bytes to send.
    ///   - flags: Send flags.
    /// - Returns: Number of bytes sent.
    /// - Throws: `Error.send` on failure.
    ///
    /// ## Partial Sends
    ///
    /// The return value may be less than `length` if the send buffer is full
    /// or for other reasons. Callers should loop to send remaining data.
    public static func send(
        _ socket: borrowing Windows.Kernel.Socket.Descriptor,
        buffer: UnsafeRawPointer,
        length: Int,
        flags: SendFlags = .none
    ) throws(Error) -> Int {
        try send(socket._rawValue, buffer: buffer, length: length, flags: flags)
    }

    /// Sends data on a SOCKET bit pattern.
    ///
    /// Spec-literal raw `send`. The typed L2 convenience
    /// (`send(_:buffer:length:flags:)` taking
    /// `borrowing Windows.Kernel.Socket.Descriptor`) delegates to this raw SPI
    /// internally via `socket._rawValue`.
    ///
    /// - Parameters:
    ///   - socket: SOCKET bit pattern.
    ///   - buffer: Pointer to the data to send.
    ///   - length: Number of bytes to send.
    ///   - flags: Send flags.
    /// - Returns: Number of bytes sent (may be less than `length`).
    /// - Throws: `Error.send` on failure.
    @_spi(Syscall)
    public static func send(
        _ socket: UInt,
        buffer: UnsafeRawPointer,
        length: Int,
        flags: SendFlags = .none
    ) throws(Error) -> Int {
        let result = WinSDK.send(
            SOCKET(socket),
            buffer.assumingMemoryBound(to: CChar.self),
            Int32(length),
            flags.rawValue
        )
        guard result != SOCKET_ERROR else {
            throw .send(captureLastSocketError())
        }
        return Int(result)
    }

    /// Sends data on a connected socket.
    ///
    /// - Parameters:
    ///   - socket: The connected socket.
    ///   - buffer: The buffer containing data to send.
    ///   - flags: Send flags.
    /// - Returns: Number of bytes sent.
    /// - Throws: `Error.send` on failure.
    public static func send(
        _ socket: borrowing Windows.Kernel.Socket.Descriptor,
        buffer: UnsafeBufferPointer<UInt8>,
        flags: SendFlags = .none
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }
        return try send(socket, buffer: baseAddress, length: buffer.count, flags: flags)
    }

    /// Sends data to a specific destination address.
    ///
    /// Used for connectionless (datagram) sockets, or to override the
    /// destination address for connected sockets.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - buffer: Pointer to the data to send.
    ///   - length: Number of bytes to send.
    ///   - flags: Send flags.
    ///   - destAddr: Destination address.
    ///   - destAddrLength: Size of the destination address structure.
    /// - Returns: Number of bytes sent.
    /// - Throws: `Error.send` on failure.
    public static func sendTo(
        _ socket: borrowing Windows.Kernel.Socket.Descriptor,
        buffer: UnsafeRawPointer,
        length: Int,
        flags: SendFlags = .none,
        destAddr: UnsafePointer<sockaddr>,
        destAddrLength: Int32
    ) throws(Error) -> Int {
        try sendTo(
            socket._rawValue,
            buffer: buffer,
            length: length,
            flags: flags,
            destAddr: destAddr,
            destAddrLength: destAddrLength
        )
    }

    /// Sends data to a destination on a SOCKET bit pattern.
    ///
    /// Spec-literal raw `sendto`. The typed L2 convenience
    /// (`sendTo(_:buffer:length:flags:destAddr:destAddrLength:)` taking
    /// `borrowing Windows.Kernel.Socket.Descriptor`) delegates to this raw SPI
    /// internally via `socket._rawValue`.
    ///
    /// - Parameters:
    ///   - socket: SOCKET bit pattern.
    ///   - buffer: Pointer to the data to send.
    ///   - length: Number of bytes to send.
    ///   - flags: Send flags.
    ///   - destAddr: Destination address.
    ///   - destAddrLength: Size of the destination address structure.
    /// - Returns: Number of bytes sent.
    /// - Throws: `Error.send` on failure.
    @_spi(Syscall)
    public static func sendTo(
        _ socket: UInt,
        buffer: UnsafeRawPointer,
        length: Int,
        flags: SendFlags = .none,
        destAddr: UnsafePointer<sockaddr>,
        destAddrLength: Int32
    ) throws(Error) -> Int {
        let result = sendto(
            SOCKET(socket),
            buffer.assumingMemoryBound(to: CChar.self),
            Int32(length),
            flags.rawValue,
            destAddr,
            destAddrLength
        )
        guard result != SOCKET_ERROR else {
            throw .send(captureLastSocketError())
        }
        return Int(result)
    }
}

#endif
