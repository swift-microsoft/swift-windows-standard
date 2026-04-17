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

@_spi(Syscall) public import Kernel_Primitives_Core
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
@_spi(Syscall) public import Kernel_Thread_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
public import Windows_Standard_Core

extension Windows_Standard_Core.Windows {
    /// Windows kernel mechanisms.
    ///
    /// This is a typealias to `Kernel_Primitives_Core.Kernel`, allowing Windows-specific
    /// extensions to be added to the shared Kernel type.
    ///
    /// Low-level Windows syscall wrappers for:
    /// - I/O Completion Ports (IOCP) for async I/O
    /// - File I/O (CreateFileW, ReadFile, WriteFile, CloseHandle)
    /// - File seeking (SetFilePointerEx)
    /// - Directory operations
    /// - Process management
    /// - Memory mapping
    public typealias Kernel = Kernel_Primitives_Core.Kernel
}

// MARK: - Windows.Kernel.Descriptor Veneer

#if os(Windows)
public import WinSDK

extension Kernel_Primitives_Core.Kernel.Descriptor {
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
