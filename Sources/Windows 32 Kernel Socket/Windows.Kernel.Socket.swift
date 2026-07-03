// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-standard open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
public import Error_Primitives
public import WinSDK

// MARK: - Winsock Initialization

extension Windows.`32`.Kernel.Socket {
    /// Initializes Winsock2 library.
    ///
    /// Must be called before any other socket operations. Each successful
    /// call to `startup()` must be balanced with a call to `cleanup()`.
    ///
    /// - Throws: `Error.startup` if initialization fails.
    ///
    /// ## Thread Safety
    ///
    /// Thread-safe. Winsock uses reference counting for startup/cleanup.
    public static func startup() throws(Error) {
        var wsaData = WSADATA()
        let result = WSAStartup(MAKEWORD(2, 2), &wsaData)
        guard result == 0 else {
            throw .platform(Error_Primitives.Error(code: Error_Primitives.Error.Code.win32(DWORD(result))))
        }
    }

    /// Cleans up Winsock2 library.
    ///
    /// Decrements the reference count. When it reaches zero, the library
    /// is unloaded. Must be called once for each successful `startup()`.
    ///
    /// - Returns: `true` if cleanup succeeded, `false` otherwise.
    @discardableResult
    public static func cleanup() -> Bool {
        WSACleanup() == 0
    }
}

// MARK: - Socket Creation

extension Windows.`32`.Kernel.Socket {
    /// Address family for sockets.
    public struct Family: RawRepresentable, Sendable, Equatable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }

    /// Socket type.
    public struct SocketType: RawRepresentable, Sendable, Equatable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }

    /// Socket protocol.
    public struct `Protocol`: RawRepresentable, Sendable, Equatable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension Windows.`32`.Kernel.Socket.Family {
    /// IPv4 address family.
    public static let inet = Self(rawValue: AF_INET)

    /// IPv6 address family.
    public static let inet6 = Self(rawValue: AF_INET6)

    /// Unix domain sockets (AF_UNIX).
    public static let unix = Self(rawValue: AF_UNIX)

    /// Unspecified address family.
    public static let unspec = Self(rawValue: AF_UNSPEC)
}

extension Windows.`32`.Kernel.Socket.SocketType {
    /// Stream socket (TCP).
    public static let stream = Self(rawValue: SOCK_STREAM)

    /// Datagram socket (UDP).
    public static let datagram = Self(rawValue: SOCK_DGRAM)

    /// Raw socket.
    public static let raw = Self(rawValue: SOCK_RAW)
}

extension Windows.`32`.Kernel.Socket.`Protocol` {
    /// TCP protocol.
    public static let tcp = Self(rawValue: IPPROTO_TCP.rawValue)

    /// UDP protocol.
    public static let udp = Self(rawValue: IPPROTO_UDP.rawValue)

    /// Default protocol (let system choose).
    public static let `default` = Self(rawValue: 0)
}

extension Windows.`32`.Kernel.Socket {
    /// Creates a socket.
    ///
    /// - Parameters:
    ///   - family: The address family (IPv4, IPv6, etc.).
    ///   - type: The socket type (stream, datagram, etc.).
    ///   - protocol: The protocol (TCP, UDP, or default).
    /// - Returns: The socket descriptor.
    /// - Throws: `Error.create` on failure.
    public static func create(
        family: Family,
        type: SocketType,
        protocol: `Protocol` = .default
    ) throws(Error) -> Windows.`32`.Kernel.Socket.Descriptor {
        let sock = socket(family.rawValue, type.rawValue, `protocol`.rawValue)
        guard sock != INVALID_SOCKET else {
            throw .platform(Error_Primitives.Error(code: captureLastSocketError()))
        }
        return Windows.`32`.Kernel.Socket.Descriptor(_rawValue: UInt(sock))
    }

    /// Closes a socket by consuming ownership.
    ///
    /// Takes ownership of the descriptor; the `deinit` handles `closesocket`.
    ///
    /// - Parameter socket: The socket to close (ownership transferred).
    public static func close(_ socket: consuming Windows.`32`.Kernel.Socket.Descriptor) {
        // Deinit handles closesocket.
    }
}

// MARK: - MAKEWORD Helper

/// Creates a WORD value from two bytes.
@inlinable
internal func MAKEWORD(_ low: UInt8, _ high: UInt8) -> WORD {
    WORD(low) | (WORD(high) << 8)
}

// MARK: - Error Capture

/// Captures the current Winsock error as a Error_Primitives.Error.Code.
@usableFromInline
internal func captureLastSocketError() -> Error_Primitives.Error.Code {
    .win32(DWORD(WSAGetLastError()))
}

#endif
