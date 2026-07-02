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
internal import WinSDK
#endif

extension Windows.`32`.Kernel {
    /// Windows file/object descriptor (HANDLE).
    ///
    /// `~Copyable` move-only wrapper around the Windows `HANDLE` (UInt-shaped).
    /// The `deinit` closes the handle via `CloseHandle` when the value is
    /// dropped without explicit close.
    ///
    /// Use ``Kernel/Close/close(_:)`` for explicit close with error reporting.
    ///
    /// ## Design
    ///
    /// Raw value access is public, mirroring `ISO_9945.Kernel.Descriptor`
    /// (`_rawValue: Int32` there, `UInt`-shaped `HANDLE` here). Application
    /// code should use the unified API in swift-kernel, where
    /// `Kernel.Descriptor` resolves to this type on Windows.
    public struct Descriptor: ~Copyable, Sendable {
        /// The raw-representation type (`HANDLE` bit pattern).
        ///
        /// The POSIX counterpart is `Int32`; consumers that surface the
        /// platform handle spell it `Kernel.Descriptor.RawValue`.
        public typealias RawValue = UInt

        @usableFromInline
        package var _raw: UInt

        @usableFromInline
        package init(_raw: UInt) {
            self._raw = _raw
        }

        deinit {
            guard isValid else { return }
            #if os(Windows)
            _ = unsafe CloseHandle(UnsafeMutableRawPointer(bitPattern: _raw)!)
            #endif
        }

        /// Invalid handle sentinel (`INVALID_HANDLE_VALUE`, all bits set).
        public static var invalid: Descriptor {
            Descriptor(_raw: ~0)
        }

        /// Whether the handle is valid (not the sentinel).
        @inlinable
        public var isValid: Bool {
            _raw != ~0
        }
    }
}

// MARK: - SPI for Syscall Layers

extension Windows.`32`.Kernel.Descriptor {
    /// Creates a descriptor from a raw Windows `HANDLE` value.
    ///
    /// Public per ISO 9945 parity (`ISO_9945.Kernel.Descriptor.init(_rawValue:)`).
    @inlinable
    public init(_rawValue: UInt) {
        self._raw = _rawValue
    }

    /// The raw Windows `HANDLE` value.
    ///
    /// Public per ISO 9945 parity (`ISO_9945.Kernel.Descriptor._rawValue`).
    @inlinable
    public var _rawValue: UInt { _raw }
}
