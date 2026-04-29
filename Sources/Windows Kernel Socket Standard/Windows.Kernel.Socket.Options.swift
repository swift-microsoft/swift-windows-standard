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
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_Socket_Primitives
public import WinSDK

// MARK: - Socket Options

extension Windows.Kernel.Socket {
    /// Socket option level.
    public struct OptionLevel: RawRepresentable, Sendable, Equatable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Socket-level options.
        public static let socket = OptionLevel(rawValue: SOL_SOCKET)

        /// TCP-level options.
        public static let tcp = OptionLevel(rawValue: IPPROTO_TCP)

        /// IPv4-level options.
        public static let ipv4 = OptionLevel(rawValue: IPPROTO_IP)

        /// IPv6-level options.
        public static let ipv6 = OptionLevel(rawValue: IPPROTO_IPV6)
    }

    /// Socket option name.
    public struct OptionName: RawRepresentable, Sendable, Equatable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        // MARK: - SOL_SOCKET Options

        /// Allow reuse of local addresses.
        public static let reuseAddr = OptionName(rawValue: SO_REUSEADDR)

        /// Keep connections alive.
        public static let keepAlive = OptionName(rawValue: SO_KEEPALIVE)

        /// Receive buffer size.
        public static let receiveBuffer = OptionName(rawValue: SO_RCVBUF)

        /// Send buffer size.
        public static let sendBuffer = OptionName(rawValue: SO_SNDBUF)

        /// Receive timeout.
        public static let receiveTimeout = OptionName(rawValue: SO_RCVTIMEO)

        /// Send timeout.
        public static let sendTimeout = OptionName(rawValue: SO_SNDTIMEO)

        /// Linger on close.
        public static let linger = OptionName(rawValue: SO_LINGER)

        /// Get socket error status.
        public static let error = OptionName(rawValue: SO_ERROR)

        /// Get socket type.
        public static let type = OptionName(rawValue: SO_TYPE)

        /// Enable broadcast.
        public static let broadcast = OptionName(rawValue: SO_BROADCAST)

        /// Enable out-of-band inline.
        public static let oobInline = OptionName(rawValue: SO_OOBINLINE)

        // MARK: - IPPROTO_TCP Options

        /// Disable Nagle algorithm.
        public static let tcpNoDelay = OptionName(rawValue: TCP_NODELAY)

        // MARK: - IPPROTO_IPV6 Options

        /// Restrict to IPv6 only.
        public static let ipv6Only = OptionName(rawValue: IPV6_V6ONLY)
    }

    /// Gets a socket option.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - level: Option level (socket, TCP, IP, etc.).
    ///   - name: Option name.
    ///   - value: Pointer to receive the option value.
    ///   - length: On input, size of the value buffer.
    ///             On output, actual size of the returned value.
    /// - Throws: `Error.getOption` on failure.
    public static func getOption(
        _ socket: borrowing Kernel.Socket.Descriptor,
        level: OptionLevel,
        name: OptionName,
        value: UnsafeMutableRawPointer,
        length: UnsafeMutablePointer<Int32>
    ) throws(Error) {
        try getOption(socket._rawValue, level: level, name: name, value: value, length: length)
    }

    /// Gets a socket option on a SOCKET bit pattern.
    ///
    /// Spec-literal raw `getsockopt`. The typed L2 convenience
    /// (`getOption(_:level:name:value:length:)` taking
    /// `borrowing Kernel.Socket.Descriptor`) delegates to this raw SPI
    /// internally via `socket._rawValue`.
    ///
    /// - Parameters:
    ///   - socket: SOCKET bit pattern.
    ///   - level: Option level (socket, TCP, IP, etc.).
    ///   - name: Option name.
    ///   - value: Pointer to receive the option value.
    ///   - length: On input, size of the value buffer. On output, actual size.
    /// - Throws: `Error.getOption` on failure.
    @_spi(Syscall)
    public static func getOption(
        _ socket: UInt,
        level: OptionLevel,
        name: OptionName,
        value: UnsafeMutableRawPointer,
        length: UnsafeMutablePointer<Int32>
    ) throws(Error) {
        let result = getsockopt(
            SOCKET(socket),
            level.rawValue,
            name.rawValue,
            value.assumingMemoryBound(to: CChar.self),
            length
        )
        guard result == 0 else {
            throw .getOption(captureLastSocketError())
        }
    }

    /// Sets a socket option.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - level: Option level (socket, TCP, IP, etc.).
    ///   - name: Option name.
    ///   - value: Pointer to the option value.
    ///   - length: Size of the option value.
    /// - Throws: `Error.setOption` on failure.
    public static func setOption(
        _ socket: borrowing Kernel.Socket.Descriptor,
        level: OptionLevel,
        name: OptionName,
        value: UnsafeRawPointer,
        length: Int32
    ) throws(Error) {
        try setOption(socket._rawValue, level: level, name: name, value: value, length: length)
    }

    /// Sets a socket option on a SOCKET bit pattern.
    ///
    /// Spec-literal raw `setsockopt`. The typed L2 convenience
    /// (`setOption(_:level:name:value:length:)` taking
    /// `borrowing Kernel.Socket.Descriptor`) delegates to this raw SPI
    /// internally via `socket._rawValue`.
    ///
    /// - Parameters:
    ///   - socket: SOCKET bit pattern.
    ///   - level: Option level (socket, TCP, IP, etc.).
    ///   - name: Option name.
    ///   - value: Pointer to the option value.
    ///   - length: Size of the option value.
    /// - Throws: `Error.setOption` on failure.
    @_spi(Syscall)
    public static func setOption(
        _ socket: UInt,
        level: OptionLevel,
        name: OptionName,
        value: UnsafeRawPointer,
        length: Int32
    ) throws(Error) {
        let result = setsockopt(
            SOCKET(socket),
            level.rawValue,
            name.rawValue,
            value.assumingMemoryBound(to: CChar.self),
            length
        )
        guard result == 0 else {
            throw .setOption(captureLastSocketError())
        }
    }

    // MARK: - Convenience Methods

    /// Gets a boolean socket option.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - level: Option level.
    ///   - name: Option name.
    /// - Returns: The boolean option value.
    /// - Throws: `Error.getOption` on failure.
    public static func getBoolOption(
        _ socket: borrowing Kernel.Socket.Descriptor,
        level: OptionLevel,
        name: OptionName
    ) throws(Error) -> Bool {
        var value: Int32 = 0
        var length = Int32(MemoryLayout<Int32>.size)
        try getOption(socket, level: level, name: name, value: &value, length: &length)
        return value != 0
    }

    /// Sets a boolean socket option.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - level: Option level.
    ///   - name: Option name.
    ///   - value: The boolean value to set.
    /// - Throws: `Error.setOption` on failure.
    public static func setBoolOption(
        _ socket: borrowing Kernel.Socket.Descriptor,
        level: OptionLevel,
        name: OptionName,
        value: Bool
    ) throws(Error) {
        var intValue: Int32 = value ? 1 : 0
        try setOption(
            socket,
            level: level,
            name: name,
            value: &intValue,
            length: Int32(MemoryLayout<Int32>.size)
        )
    }

    /// Gets an integer socket option.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - level: Option level.
    ///   - name: Option name.
    /// - Returns: The integer option value.
    /// - Throws: `Error.getOption` on failure.
    public static func getIntOption(
        _ socket: borrowing Kernel.Socket.Descriptor,
        level: OptionLevel,
        name: OptionName
    ) throws(Error) -> Int32 {
        var value: Int32 = 0
        var length = Int32(MemoryLayout<Int32>.size)
        try getOption(socket, level: level, name: name, value: &value, length: &length)
        return value
    }

    /// Sets an integer socket option.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - level: Option level.
    ///   - name: Option name.
    ///   - value: The integer value to set.
    /// - Throws: `Error.setOption` on failure.
    public static func setIntOption(
        _ socket: borrowing Kernel.Socket.Descriptor,
        level: OptionLevel,
        name: OptionName,
        value: Int32
    ) throws(Error) {
        var intValue = value
        try setOption(
            socket,
            level: level,
            name: name,
            value: &intValue,
            length: Int32(MemoryLayout<Int32>.size)
        )
    }

    // MARK: - Common Operations

    /// Enables or disables address reuse.
    ///
    /// When enabled, allows binding to an address that is already in use.
    /// Commonly used for server sockets to enable quick restart.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - enabled: Whether to enable address reuse.
    /// - Throws: `Error.setOption` on failure.
    public static func setReuseAddress(
        _ socket: borrowing Kernel.Socket.Descriptor,
        enabled: Bool
    ) throws(Error) {
        try setBoolOption(socket, level: .socket, name: .reuseAddr, value: enabled)
    }

    /// Enables or disables the Nagle algorithm.
    ///
    /// When TCP_NODELAY is enabled (Nagle disabled), small packets are
    /// sent immediately without waiting to coalesce with other data.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - enabled: Whether to disable Nagle (true = no delay).
    /// - Throws: `Error.setOption` on failure.
    public static func setNoDelay(
        _ socket: borrowing Kernel.Socket.Descriptor,
        enabled: Bool
    ) throws(Error) {
        try setBoolOption(socket, level: .tcp, name: .tcpNoDelay, value: enabled)
    }

    /// Gets the socket error status.
    ///
    /// Retrieves and clears the pending socket error.
    ///
    /// - Parameter socket: The socket.
    /// - Returns: The error code, or 0 if no error.
    /// - Throws: `Error.getOption` on failure.
    public static func getError(
        _ socket: borrowing Kernel.Socket.Descriptor
    ) throws(Error) -> Int32 {
        try getIntOption(socket, level: .socket, name: .error)
    }

    /// Sets the receive buffer size.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - size: Buffer size in bytes.
    /// - Throws: `Error.setOption` on failure.
    public static func setReceiveBuffer(
        _ socket: borrowing Kernel.Socket.Descriptor,
        size: Int32
    ) throws(Error) {
        try setIntOption(socket, level: .socket, name: .receiveBuffer, value: size)
    }

    /// Sets the send buffer size.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - size: Buffer size in bytes.
    /// - Throws: `Error.setOption` on failure.
    public static func setSendBuffer(
        _ socket: borrowing Kernel.Socket.Descriptor,
        size: Int32
    ) throws(Error) {
        try setIntOption(socket, level: .socket, name: .sendBuffer, value: size)
    }

    /// Enables or disables keep-alive probes.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - enabled: Whether to enable keep-alive.
    /// - Throws: `Error.setOption` on failure.
    public static func setKeepAlive(
        _ socket: borrowing Kernel.Socket.Descriptor,
        enabled: Bool
    ) throws(Error) {
        try setBoolOption(socket, level: .socket, name: .keepAlive, value: enabled)
    }
}

// MARK: - Socket Name Operations

extension Windows.Kernel.Socket {
    /// Gets the local address of a socket.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - address: Pointer to receive the address.
    ///   - addressLength: On input, size of the address buffer.
    ///                    On output, actual size of the returned address.
    /// - Throws: `Error.getSockName` on failure.
    public static func getSockName(
        _ socket: borrowing Kernel.Socket.Descriptor,
        address: UnsafeMutablePointer<sockaddr>,
        addressLength: UnsafeMutablePointer<Int32>
    ) throws(Error) {
        try getSockName(socket._rawValue, address: address, addressLength: addressLength)
    }

    /// Gets the local address on a SOCKET bit pattern.
    ///
    /// Spec-literal raw `getsockname`. The typed L2 convenience
    /// (`getSockName(_:address:addressLength:)` taking
    /// `borrowing Kernel.Socket.Descriptor`) delegates to this raw SPI
    /// internally via `socket._rawValue`.
    ///
    /// - Parameters:
    ///   - socket: SOCKET bit pattern.
    ///   - address: Pointer to receive the address.
    ///   - addressLength: On input, size of the address buffer.
    ///                    On output, actual size of the returned address.
    /// - Throws: `Error.getSockName` on failure.
    @_spi(Syscall)
    public static func getSockName(
        _ socket: UInt,
        address: UnsafeMutablePointer<sockaddr>,
        addressLength: UnsafeMutablePointer<Int32>
    ) throws(Error) {
        let result = getsockname(SOCKET(socket), address, addressLength)
        guard result == 0 else {
            throw .getSockName(captureLastSocketError())
        }
    }

    /// Gets the remote address of a connected socket.
    ///
    /// - Parameters:
    ///   - socket: The socket.
    ///   - address: Pointer to receive the address.
    ///   - addressLength: On input, size of the address buffer.
    ///                    On output, actual size of the returned address.
    /// - Throws: `Error.getPeerName` on failure.
    public static func getPeerName(
        _ socket: borrowing Kernel.Socket.Descriptor,
        address: UnsafeMutablePointer<sockaddr>,
        addressLength: UnsafeMutablePointer<Int32>
    ) throws(Error) {
        try getPeerName(socket._rawValue, address: address, addressLength: addressLength)
    }

    /// Gets the remote address on a SOCKET bit pattern.
    ///
    /// Spec-literal raw `getpeername`. The typed L2 convenience
    /// (`getPeerName(_:address:addressLength:)` taking
    /// `borrowing Kernel.Socket.Descriptor`) delegates to this raw SPI
    /// internally via `socket._rawValue`.
    ///
    /// - Parameters:
    ///   - socket: SOCKET bit pattern.
    ///   - address: Pointer to receive the address.
    ///   - addressLength: On input, size of the address buffer.
    ///                    On output, actual size of the returned address.
    /// - Throws: `Error.getPeerName` on failure.
    @_spi(Syscall)
    public static func getPeerName(
        _ socket: UInt,
        address: UnsafeMutablePointer<sockaddr>,
        addressLength: UnsafeMutablePointer<Int32>
    ) throws(Error) {
        let result = getpeername(SOCKET(socket), address, addressLength)
        guard result == 0 else {
            throw .getPeerName(captureLastSocketError())
        }
    }
}

#endif
