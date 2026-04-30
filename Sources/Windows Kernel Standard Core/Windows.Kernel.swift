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

public import Windows_Standard_Core
public import Kernel_Namespace

extension Windows_Standard_Core.Windows {
    /// Windows kernel mechanisms — typealias to the shared `Kernel` namespace.
    public typealias Kernel = Kernel_Namespace.Kernel
}

// MARK: - Windows.Kernel.Descriptor Veneer

#if os(Windows)
public import WinSDK

extension Kernel_Namespace.Kernel.Descriptor {
    /// Creates a descriptor by borrowing a Windows HANDLE.
    ///
    /// - Parameter handle: The raw Windows HANDLE.
    /// - Returns: A `Kernel.Descriptor` wrapping the handle.
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
