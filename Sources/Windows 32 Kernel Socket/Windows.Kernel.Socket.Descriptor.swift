// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
    internal import WinSDK

    extension Windows.`32`.Kernel.Socket {
        /// Windows socket descriptor with `closesocket`-on-deinit policy.
        ///
        /// On Windows, sockets are NOT file descriptors — they are `SOCKET`
        /// values (HANDLE-shaped) that must be closed via `closesocket(2)`,
        /// not `CloseHandle`. This type wraps the raw socket value with the
        /// proper Winsock cleanup behavior.
        public struct Descriptor: ~Copyable, Sendable {
            @usableFromInline
            package var _raw: UInt64

            @usableFromInline
            package init(_raw: UInt64) {
                self._raw = _raw
            }

            deinit {
                guard isValid else { return }
                #if os(Windows)
                    _ = unsafe closesocket(SOCKET(_raw))
                #endif
            }
        }
    }

    extension Windows.`32`.Kernel.Socket.Descriptor {
        /// Invalid socket descriptor sentinel (`UInt64.max`, mirroring `INVALID_SOCKET`).
        public static var invalid: Self {
            Self(_raw: UInt64.max)
        }

        /// Whether the socket descriptor is valid (not the sentinel).
        @inlinable
        public var isValid: Bool {
            _raw != UInt64.max
        }
    }

    // MARK: - SPI for Syscall Layers

    extension Windows.`32`.Kernel.Socket.Descriptor {
        /// Creates a socket descriptor from a raw Windows SOCKET value.
        @inlinable
        package init(_rawValue: UInt) {
            self.init(_raw: UInt64(_rawValue))
        }

        /// The raw Windows SOCKET value.
        @inlinable
        package var _rawValue: UInt { UInt(_raw) }
    }
#endif
