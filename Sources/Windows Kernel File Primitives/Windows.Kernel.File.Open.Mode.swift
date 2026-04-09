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
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
public import WinSDK

// MARK: - Windows file open mode conversion

extension Kernel.File.Open.Mode {
    /// Converts the mode to Windows desired access flags.
    ///
    /// Maps the portable `Mode` flags to Win32 `GENERIC_READ` and `GENERIC_WRITE`.
    @usableFromInline
    internal var windowsDesiredAccess: DWORD {
        var access: DWORD = 0

        if contains(.read) {
            access |= DWORD(GENERIC_READ)
        }
        if contains(.write) {
            access |= DWORD(GENERIC_WRITE)
        }

        return access
    }
}

#endif
