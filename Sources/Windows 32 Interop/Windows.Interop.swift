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
public import WinSDK
public import Windows_32_Core

extension Windows_32_Core.Windows {
    /// Windows SDK interoperability helpers.
    ///
    /// Provides type conversions and adapters for working with Windows APIs.
    public enum Interop {}
}

// MARK: - DWORD Conversion Helpers

extension Windows_32_Core.Windows.Interop {
    /// Converts a UInt32 value to DWORD.
    ///
    /// On Windows, DWORD is a typealias for UInt32, so this is an identity conversion.
    @inline(always)
    public static func dword(_ value: UInt32) -> DWORD { value }

    /// Converts an Int32 value to DWORD using bit-preserving conversion.
    ///
    /// This handles Windows API constants that may be typed as signed integers.
    @inline(always)
    public static func dword(_ value: Int32) -> DWORD { DWORD(bitPattern: value) }
}

// MARK: - Mask Helpers for Bitwise Operations

extension Windows_32_Core.Windows.Interop {
    /// Converts a UInt32 value to DWORD for mask operations.
    @inline(always)
    public static func mask(_ value: UInt32) -> DWORD { value }

    /// Converts an Int32 value to DWORD for mask operations using bit-preserving conversion.
    @inline(always)
    public static func mask(_ value: Int32) -> DWORD { DWORD(bitPattern: value) }
}

// MARK: - Boolean Adapters

extension Windows_32_Core.Windows.Interop {
    /// Identity adapter for Windows API return values that return Bool.
    ///
    /// In Swift 6.2, the WinSDK overlay has converted most Windows APIs to return Swift Bool.
    /// This adapter provides a consistent interface for checking API success.
    @inline(always)
    public static func ok(_ value: Bool) -> Bool { value }

    /// Adapter for Windows APIs that return BOOLEAN (UInt8).
    ///
    /// Some APIs like CreateSymbolicLinkW still return BOOLEAN.
    @inline(always)
    public static func ok(_ value: BOOLEAN) -> Bool { value != 0 }
}
#endif
