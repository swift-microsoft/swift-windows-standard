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

// Windows.Kernel canonical declaration lives at Windows.Kernel.Namespace.swift
// (G6.D typealias-via-L3 pattern). This file holds Windows-specific
// veneer extensions on Windows.Kernel.Descriptor.

// MARK: - Windows.Kernel.Descriptor Veneer

#if os(Windows)
public import WinSDK

extension Windows_32_Core.Windows.Kernel.Descriptor {
    /// Creates a descriptor by borrowing a Windows HANDLE.
    ///
    /// - Parameter handle: The raw Windows HANDLE.
    /// - Returns: A `Windows.Kernel.Descriptor` wrapping the handle.
    @inlinable
    public static func borrowing(handle: HANDLE) -> Self {
        Self(_rawValue: UInt(bitPattern: handle))
    }

    /// The raw Windows HANDLE value.
    @inlinable
    public var handle: HANDLE {
        HANDLE(bitPattern: _rawValue)!
    }
}
#endif
