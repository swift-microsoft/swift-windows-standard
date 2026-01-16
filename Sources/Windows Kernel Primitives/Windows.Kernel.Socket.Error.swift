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

// MARK: - Socket Error Type

extension Windows.Kernel.Socket {
    /// Errors from Winsock2 socket operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Winsock startup failed.
        case startup(Kernel.Error.Code)

        /// Socket creation failed.
        case create(Kernel.Error.Code)

        /// Socket close failed.
        case close(Kernel.Error.Code)

        /// Bind operation failed.
        case bind(Kernel.Error.Code)

        /// Listen operation failed.
        case listen(Kernel.Error.Code)

        /// Accept operation failed.
        case accept(Kernel.Error.Code)

        /// Connect operation failed.
        case connect(Kernel.Error.Code)

        /// Send operation failed.
        case send(Kernel.Error.Code)

        /// Receive operation failed.
        case receive(Kernel.Error.Code)

        /// Shutdown operation failed.
        case shutdown(Kernel.Error.Code)

        /// Get socket option failed.
        case getOption(Kernel.Error.Code)

        /// Set socket option failed.
        case setOption(Kernel.Error.Code)

        /// Get peer name failed.
        case getPeerName(Kernel.Error.Code)

        /// Get socket name failed.
        case getSockName(Kernel.Error.Code)
    }
}

// MARK: - CustomStringConvertible

extension Windows.Kernel.Socket.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .startup(let code):
            return "WSAStartup failed (\(code))"
        case .create(let code):
            return "socket failed (\(code))"
        case .close(let code):
            return "closesocket failed (\(code))"
        case .bind(let code):
            return "bind failed (\(code))"
        case .listen(let code):
            return "listen failed (\(code))"
        case .accept(let code):
            return "accept failed (\(code))"
        case .connect(let code):
            return "connect failed (\(code))"
        case .send(let code):
            return "send failed (\(code))"
        case .receive(let code):
            return "recv failed (\(code))"
        case .shutdown(let code):
            return "shutdown failed (\(code))"
        case .getOption(let code):
            return "getsockopt failed (\(code))"
        case .setOption(let code):
            return "setsockopt failed (\(code))"
        case .getPeerName(let code):
            return "getpeername failed (\(code))"
        case .getSockName(let code):
            return "getsockname failed (\(code))"
        }
    }
}

// MARK: - Error Capture

/// Captures the current Winsock error as a Kernel.Error.Code.
@usableFromInline
internal func captureLastSocketError() -> Kernel.Error.Code {
    .win32(DWORD(WSAGetLastError()))
}

// MARK: - Common Winsock Error Codes

extension Windows.Kernel.Socket.Error {
    /// Common Winsock error codes.
    public enum Code {
        /// Connection errors.
        public enum Connection {
            /// Connection refused.
            public static let refused: Int32 = WSAECONNREFUSED

            /// Connection reset by peer.
            public static let reset: Int32 = WSAECONNRESET

            /// Connection aborted.
            public static let aborted: Int32 = WSAECONNABORTED

            /// Connection timed out.
            public static let timedOut: Int32 = WSAETIMEDOUT

            /// Network is unreachable.
            public static let networkUnreachable: Int32 = WSAENETUNREACH

            /// Host is unreachable.
            public static let hostUnreachable: Int32 = WSAEHOSTUNREACH

            /// Connection already in progress.
            public static let inProgress: Int32 = WSAEINPROGRESS

            /// Connection is already connected.
            public static let isConnected: Int32 = WSAEISCONN

            /// Socket is not connected.
            public static let notConnected: Int32 = WSAENOTCONN
        }

        /// Address errors.
        public enum Address {
            /// Address already in use.
            public static let inUse: Int32 = WSAEADDRINUSE

            /// Cannot assign requested address.
            public static let notAvailable: Int32 = WSAEADDRNOTAVAIL

            /// Address family not supported.
            public static let familyNotSupported: Int32 = WSAEAFNOSUPPORT
        }

        /// Operation errors.
        public enum Operation {
            /// Operation would block.
            public static let wouldBlock: Int32 = WSAEWOULDBLOCK

            /// Operation now in progress.
            public static let inProgress: Int32 = WSAEINPROGRESS

            /// Operation already in progress.
            public static let alreadyInProgress: Int32 = WSAEALREADY

            /// Interrupted function call.
            public static let interrupted: Int32 = WSAEINTR
        }

        /// Socket state errors.
        public enum State {
            /// Socket is already connected.
            public static let isConnected: Int32 = WSAEISCONN

            /// Socket is not connected.
            public static let notConnected: Int32 = WSAENOTCONN

            /// Socket operation on non-socket.
            public static let notSocket: Int32 = WSAENOTSOCK

            /// Socket is already bound.
            public static let alreadyBound: Int32 = WSAEINVAL
        }

        /// Buffer/message errors.
        public enum Buffer {
            /// Message too long.
            public static let messageTooLong: Int32 = WSAEMSGSIZE

            /// No buffer space available.
            public static let noBufferSpace: Int32 = WSAENOBUFS
        }

        /// Shutdown errors.
        public enum Shutdown {
            /// Cannot send after socket shutdown.
            public static let send: Int32 = WSAESHUTDOWN
        }

        /// Winsock startup errors.
        public enum Startup {
            /// Winsock not initialized.
            public static let notInitialized: Int32 = WSANOTINITIALISED

            /// Network subsystem failed.
            public static let networkDown: Int32 = WSAENETDOWN

            /// Winsock version not supported.
            public static let versionNotSupported: Int32 = WSAVERNOTSUPPORTED
        }
    }
}

#endif
