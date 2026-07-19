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

public import Windows_32_Core

// Windows.`32`.Kernel canonical declaration lives at Windows.`32`.Kernel.Namespace.swift
// (G6.D typealias-via-L3 pattern). This file holds Windows-specific
// veneer extensions on Windows.`32`.Kernel.Descriptor.

// MARK: - Windows.`32`.Kernel.Descriptor Veneer

#if os(Windows)
    public import WinSDK

    extension Windows_32_Core.Windows.`32`.Kernel.Descriptor {
        /// Creates a descriptor that takes ownership of a Windows HANDLE.
        ///
        /// `Descriptor` is `~Copyable` with a `deinit` that closes the
        /// wrapped handle via `CloseHandle` (see
        /// ``Windows_32_Core/Windows/32/Kernel/Descriptor``). Every
        /// `Descriptor` — including one produced here — closes its handle
        /// on drop; there is no non-owning "borrowed" variant of this type.
        /// Naming this `owning(handle:)` makes that unconditional close
        /// visible at the call site. Callers that must not have the handle
        /// closed (e.g. a HANDLE owned by another component, or a
        /// process-lifetime constant such as `GetStdHandle`'s result)
        /// must not construct a `Descriptor` from it at all — read the
        /// value through the raw `HANDLE` directly instead.
        ///
        /// - Parameter handle: The raw Windows HANDLE to adopt. Ownership
        ///   transfers to the returned descriptor: it will be closed when
        ///   the descriptor is dropped (or explicitly via
        ///   ``Kernel/Close/close(_:)``).
        /// - Returns: A `Windows.`32`.Kernel.Descriptor` owning the handle.
        public static func owning(handle: HANDLE) -> Self {
            Self(_rawValue: UInt(bitPattern: handle))
        }

        /// The raw Windows HANDLE value.
        public var handle: HANDLE {
            HANDLE(bitPattern: _rawValue)!
        }
    }
#endif
