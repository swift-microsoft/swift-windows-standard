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

    // MARK: - Socket Accept (raw @_spi(Syscall))

    extension Windows.`32`.Kernel.Socket {
        /// Accepts an incoming connection on a SOCKET bit pattern.
        ///
        /// Spec-literal raw `accept`. The typed L2 convenience (`accept(_:)`
        /// taking `borrowing Windows.`32`.Kernel.Socket.Descriptor`) delegates to this raw
        /// SPI internally via `socket._rawValue`.
        ///
        /// - Parameter socket: SOCKET bit pattern (listening).
        /// - Returns: New connected SOCKET bit pattern.
        /// - Throws: `Error.accept` on failure.
        package static func accept(
            _ socket: UInt
        ) throws(Error) -> UInt {
            let clientSocket = WinSDK.accept(SOCKET(socket), nil, nil)
            guard clientSocket != INVALID_SOCKET else {
                throw .platform(Error_Primitives.Error(code: captureLastSocketError()))
            }
            return UInt(clientSocket)
        }

        /// Accepts an incoming connection on a SOCKET bit pattern, retrieving the client address.
        ///
        /// Spec-literal raw `accept`. The typed L2 convenience
        /// (`accept(_:address:addressLength:)` taking
        /// `borrowing Windows.`32`.Kernel.Socket.Descriptor`) delegates to this raw SPI
        /// internally via `socket._rawValue`.
        ///
        /// - Parameters:
        ///   - socket: SOCKET bit pattern (listening).
        ///   - address: Pointer to receive the client address.
        ///   - addressLength: On input, the size of the address buffer.
        ///                    On output, the actual size of the returned address.
        /// - Returns: New connected SOCKET bit pattern.
        /// - Throws: `Error.accept` on failure.
        package static func accept(
            _ socket: UInt,
            address: UnsafeMutablePointer<sockaddr>,
            addressLength: UnsafeMutablePointer<Int32>
        ) throws(Error) -> UInt {
            let clientSocket = WinSDK.accept(SOCKET(socket), address, addressLength)
            guard clientSocket != INVALID_SOCKET else {
                throw .platform(Error_Primitives.Error(code: captureLastSocketError()))
            }
            return UInt(clientSocket)
        }

        /// Accepts an incoming connection on a listening socket.
        ///
        /// Typed L2 form. Delegates to the raw `accept(_:)` SPI via
        /// `socket._rawValue` and reconstructs the result via
        /// `Windows.`32`.Kernel.Socket.Descriptor(_rawValue:)`.
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
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor
        ) throws(Error) -> Windows.`32`.Kernel.Socket.Descriptor {
            let raw = try accept(socket._rawValue)
            return Windows.`32`.Kernel.Socket.Descriptor(_rawValue: raw)
        }

        /// Accepts an incoming connection and retrieves the client address.
        ///
        /// Typed L2 form. Delegates to the raw `accept(_:address:addressLength:)`
        /// SPI via `socket._rawValue` and reconstructs the result via
        /// `Windows.`32`.Kernel.Socket.Descriptor(_rawValue:)`.
        ///
        /// - Parameters:
        ///   - socket: The listening socket.
        ///   - address: Pointer to receive the client address.
        ///   - addressLength: On input, the size of the address buffer.
        ///                    On output, the actual size of the returned address.
        /// - Returns: The new connected socket descriptor.
        /// - Throws: `Error.accept` on failure.
        public static func accept(
            _ socket: borrowing Windows.`32`.Kernel.Socket.Descriptor,
            address: UnsafeMutablePointer<sockaddr>,
            addressLength: UnsafeMutablePointer<Int32>
        ) throws(Error) -> Windows.`32`.Kernel.Socket.Descriptor {
            let raw = try accept(socket._rawValue, address: address, addressLength: addressLength)
            return Windows.`32`.Kernel.Socket.Descriptor(_rawValue: raw)
        }
    }

#endif
