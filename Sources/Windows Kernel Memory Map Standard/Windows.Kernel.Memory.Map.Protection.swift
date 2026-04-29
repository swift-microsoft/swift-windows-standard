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
@_spi(Syscall) public import Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_Memory_Primitives
public import WinSDK

// MARK: - Windows Memory Protection Constants

extension Kernel.Memory.Map.Protection {
    /// Permits reading from mapped pages.
    public static let read = Self(rawValue: 1)

    /// Permits writing to mapped pages.
    public static let write = Self(rawValue: 2)

    /// Permits executing code from mapped pages.
    public static let execute = Self(rawValue: 4)

    /// Convenience for read and write access.
    public static let readWrite: Self = read | write

    /// Convenience for read and execute access.
    public static let readExecute: Self = read | execute
}

// MARK: - Windows Protection Conversion

extension Kernel.Memory.Map.Protection {
    /// Converts to Windows VirtualAlloc/VirtualProtect protection flags.
    @usableFromInline
    internal var windowsVirtualProtect: DWORD {
        let hasRead = contains(.read)
        let hasWrite = contains(.write)
        let hasExecute = contains(.execute)

        if hasExecute && hasWrite {
            return DWORD(PAGE_EXECUTE_READWRITE)
        } else if hasExecute && hasRead {
            return DWORD(PAGE_EXECUTE_READ)
        } else if hasExecute {
            return DWORD(PAGE_EXECUTE)
        } else if hasWrite {
            return DWORD(PAGE_READWRITE)
        } else if hasRead {
            return DWORD(PAGE_READONLY)
        } else {
            return DWORD(PAGE_NOACCESS)
        }
    }

    /// Converts to Windows CreateFileMapping protection flags.
    @usableFromInline
    internal var windowsFileMapProtect: DWORD {
        let hasRead = contains(.read)
        let hasWrite = contains(.write)
        let hasExecute = contains(.execute)

        if hasExecute && hasWrite {
            return DWORD(PAGE_EXECUTE_READWRITE)
        } else if hasExecute && hasRead {
            return DWORD(PAGE_EXECUTE_READ)
        } else if hasWrite {
            return DWORD(PAGE_READWRITE)
        } else {
            return DWORD(PAGE_READONLY)
        }
    }

    /// Converts to Windows MapViewOfFile desired access flags.
    @usableFromInline
    internal var windowsMapViewAccess: DWORD {
        let hasRead = contains(.read)
        let hasWrite = contains(.write)
        let hasExecute = contains(.execute)

        var access: DWORD = 0
        if hasWrite {
            access = DWORD(FILE_MAP_WRITE)
        } else if hasRead {
            access = DWORD(FILE_MAP_READ)
        }
        if hasExecute {
            access |= DWORD(FILE_MAP_EXECUTE)
        }
        return access
    }
}

#endif
