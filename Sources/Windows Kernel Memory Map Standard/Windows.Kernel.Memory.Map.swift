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

// MARK: - Windows Memory Mapping (raw @_spi(Syscall))

extension Windows.Kernel.Memory.Map {
    /// Maps a file into the process address space via HANDLE bit pattern.
    ///
    /// Spec-literal raw `CreateFileMappingW + MapViewOfFile`. The typed L2
    /// convenience (`map(fd:length:protection:flags:offset:)` taking
    /// `Kernel.Descriptor`) delegates to this raw SPI internally via
    /// `descriptor._rawValue`.
    ///
    /// Windows memory mapping requires two steps:
    /// 1. CreateFileMappingW to create a file mapping object
    /// 2. MapViewOfFile to map a view of that object
    ///
    /// - Parameters:
    ///   - handle: HANDLE bit pattern.
    ///   - length: Number of bytes to map (must be > 0).
    ///   - protection: Memory protection flags.
    ///   - flags: Mapping flags (shared/private).
    ///   - offset: Offset into the file.
    /// - Returns: Pointer to the mapped region.
    /// - Throws: `Error.map` on failure.
    @_spi(Syscall)
    public static func map(
        fd handle: UInt,
        length: Kernel.File.Size,
        protection: Protection,
        flags: Flags,
        offset: Kernel.File.Offset = .zero
    ) throws(Kernel.Memory.Map.Error) -> Kernel.Memory.Address {
        guard length.isPositive else {
            throw .invalid(.length)
        }

        // Create file mapping object
        let fileMappingProtect = protection.windowsFileMapProtect
        let mappingHandle = CreateFileMappingW(
            UnsafeMutableRawPointer(bitPattern: handle)!,
            nil,
            fileMappingProtect,
            DWORD((offset.rawValue + length.rawValue) >> 32),
            DWORD((offset.rawValue + length.rawValue) & 0xFFFFFFFF),
            nil
        )

        guard let mappingHandle, mappingHandle != INVALID_HANDLE_VALUE else {
            throw .map(Error_Primitives.Error.captureLastError())
        }

        // Map view of file
        let desiredAccess = protection.windowsMapViewAccess
        let baseAddress = MapViewOfFile(
            mappingHandle,
            desiredAccess,
            DWORD(offset.rawValue >> 32),
            DWORD(offset.rawValue & 0xFFFFFFFF),
            SIZE_T(length.rawValue)
        )

        // Close the mapping handle - the view keeps it alive
        _ = CloseHandle(mappingHandle)

        guard let baseAddress else {
            throw .map(Error_Primitives.Error.captureLastError())
        }

        return unsafe Kernel.Memory.Address(baseAddress)
    }

    /// Maps a file into the process address space.
    ///
    /// Typed L2 form. Delegates to the raw `map(fd:length:protection:flags:offset:)`
    /// SPI via `descriptor._rawValue`.
    ///
    /// - Parameters:
    ///   - fd: The file descriptor to map.
    ///   - length: Number of bytes to map (must be > 0).
    ///   - protection: Memory protection flags.
    ///   - flags: Mapping flags (shared/private).
    ///   - offset: Offset into the file.
    /// - Returns: Pointer to the mapped region.
    /// - Throws: `Error.map` on failure.
    public static func map(
        fd: Kernel.Descriptor,
        length: Kernel.File.Size,
        protection: Protection,
        flags: Flags,
        offset: Kernel.File.Offset = .zero
    ) throws(Kernel.Memory.Map.Error) -> Kernel.Memory.Address {
        try map(
            fd: fd._rawValue,
            length: length,
            protection: protection,
            flags: flags,
            offset: offset
        )
    }

    /// Maps anonymous memory.
    ///
    /// Uses VirtualAlloc for anonymous memory allocations.
    ///
    /// - Parameters:
    ///   - addr: Suggested address, or `nil` for system to choose.
    ///   - length: Number of bytes to map (must be > 0).
    ///   - protection: Memory protection flags.
    /// - Returns: Pointer to the mapped region.
    /// - Throws: `Error.map` on failure.
    public static func mapAnonymous(
        addr: Kernel.Memory.Address? = nil,
        length: Kernel.File.Size,
        protection: Protection
    ) throws(Kernel.Memory.Map.Error) -> Kernel.Memory.Address {
        guard length.isPositive else {
            throw .invalid(.length)
        }

        let allocationType = DWORD(MEM_COMMIT | MEM_RESERVE)
        let result = unsafe VirtualAlloc(
            addr?.mutablePointer,
            SIZE_T(length.rawValue),
            allocationType,
            protection.windowsVirtualProtect
        )

        guard let result else {
            throw .map(Error_Primitives.Error.captureLastError())
        }

        return unsafe Kernel.Memory.Address(result)
    }

    /// Unmaps a previously mapped region.
    ///
    /// - Parameters:
    ///   - addr: The base address of the mapping.
    ///   - length: The length of the mapping (ignored on Windows for file mappings).
    ///   - isAnonymous: True if this was an anonymous mapping (VirtualAlloc).
    /// - Throws: `Error.unmap` on failure.
    public static func unmap(
        addr: Kernel.Memory.Address,
        length: Kernel.File.Size,
        isAnonymous: Bool = false
    ) throws(Kernel.Memory.Map.Error) {
        let success: Bool
        if isAnonymous {
            success = unsafe VirtualFree(addr.mutablePointer, 0, DWORD(MEM_RELEASE))
        } else {
            success = unsafe UnmapViewOfFile(addr.pointer)
        }

        guard success else {
            throw .unmap(Error_Primitives.Error.captureLastError())
        }
    }

    /// Synchronizes a mapped file region to disk.
    ///
    /// - Parameters:
    ///   - addr: The base address of the region.
    ///   - length: The length of the region.
    /// - Throws: `Error.sync` on failure.
    public static func sync(
        addr: Kernel.Memory.Address,
        length: Kernel.File.Size
    ) throws(Kernel.Memory.Map.Error) {
        guard unsafe FlushViewOfFile(addr.pointer, SIZE_T(length.rawValue)) else {
            throw .sync(Error_Primitives.Error.captureLastError())
        }
    }

    /// Changes the protection on a memory region.
    ///
    /// - Parameters:
    ///   - addr: The base address (must be page-aligned).
    ///   - length: The length of the region.
    ///   - protection: The new protection flags.
    /// - Throws: `Error.protect` on failure.
    public static func protect(
        addr: Kernel.Memory.Address,
        length: Kernel.File.Size,
        protection: Protection
    ) throws(Kernel.Memory.Map.Error) {
        var oldProtect: DWORD = 0
        guard unsafe VirtualProtect(
            addr.mutablePointer,
            SIZE_T(length.rawValue),
            protection.windowsVirtualProtect,
            &oldProtect
        ) else {
            throw .protect(Error_Primitives.Error.captureLastError())
        }
    }
}

#endif
