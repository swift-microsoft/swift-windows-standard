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
    public import Error_Primitives
    public import Memory_Primitives
    public import WinSDK

    // MARK: - Windows Memory Mapping (raw @_spi(Syscall))

    extension Memory.Map {
        /// Maps a file into the process address space via HANDLE bit pattern.
        ///
        /// Spec-literal raw `CreateFileMappingW + MapViewOfFile`. The typed L2
        /// convenience (`map(fd:length:protection:flags:offset:)` taking
        /// `Windows.`32`.Kernel.Descriptor`) delegates to this raw SPI internally via
        /// `descriptor._rawValue`.
        ///
        /// Windows memory mapping requires two steps:
        /// 1. CreateFileMappingW to create a file mapping object
        /// 2. MapViewOfFile to map a view of that object
        ///
        /// `flags.isPrivate` selects a copy-on-write mapping (`PAGE_WRITECOPY`
        /// / `PAGE_EXECUTE_WRITECOPY` on the mapping object, `FILE_MAP_COPY`
        /// on the view): writes are visible only to this process and are
        /// never written back to the file. Any other `flags` value —
        /// including the default `.shared` and an empty `Options()` —
        /// produces the pre-existing shared, write-through mapping. If both
        /// `.private` and `.shared` are set, `.private` wins (checked
        /// first): the more restrictive, non-data-leaking interpretation.
        ///
        /// - Parameters:
        ///   - handle: HANDLE bit pattern.
        ///   - length: Number of bytes to map (must be > 0).
        ///   - protection: Memory protection flags.
        ///   - flags: Mapping flags (shared/private).
        ///   - offset: Offset into the file.
        /// - Returns: Pointer to the mapped region.
        /// - Throws: `Error.map` on failure.
        package static func map(
            fd handle: UInt,
            length: Memory.Address.Count,
            protection: Protection,
            flags: Options,
            offset: Windows.`32`.Kernel.File.Offset = .zero
        ) throws(Memory.Map.Error) -> Memory.Address {
            guard length.underlying.rawValue > 0 else {
                throw .invalid(.length)
            }

            let isPrivate = flags.isPrivate

            // Create file mapping object
            let fileMappingProtect = isPrivate
                ? protection.windowsFileMapProtectCopyOnWrite
                : protection.windowsFileMapProtect
            let mappingHandle = CreateFileMappingW(
                UnsafeMutableRawPointer(bitPattern: handle)!,
                nil,
                fileMappingProtect,
                DWORD((offset.underlying + Int64(length.underlying.rawValue)) >> 32),
                DWORD((offset.underlying + Int64(length.underlying.rawValue)) & 0xFFFF_FFFF),
                nil
            )

            guard let mappingHandle, mappingHandle != INVALID_HANDLE_VALUE else {
                throw .map(Error_Primitives.Error.captureLastError())
            }

            // Map view of file
            let desiredAccess = isPrivate
                ? protection.windowsMapViewAccessCopyOnWrite
                : protection.windowsMapViewAccess
            let baseAddress = MapViewOfFile(
                mappingHandle,
                desiredAccess,
                DWORD(offset.underlying >> 32),
                DWORD(offset.underlying & 0xFFFF_FFFF),
                SIZE_T(length.underlying.rawValue)
            )

            // Capture MapViewOfFile's failure error BEFORE CloseHandle runs —
            // CloseHandle overwrites the thread-local last-error, so reading it
            // after the close (as the previous code did) reported the close's
            // error, not the map's.
            let mapError = Error_Primitives.Error.captureLastError()

            // Close the mapping handle - the view keeps it alive
            _ = CloseHandle(mappingHandle)

            guard let baseAddress else {
                throw .map(mapError)
            }

            return unsafe Memory.Address(baseAddress)
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
            fd: borrowing Windows.`32`.Kernel.Descriptor,
            length: Memory.Address.Count,
            protection: Protection,
            flags: Options,
            offset: Windows.`32`.Kernel.File.Offset = .zero
        ) throws(Memory.Map.Error) -> Memory.Address {
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
            addr: Memory.Address? = nil,
            length: Memory.Address.Count,
            protection: Protection
        ) throws(Memory.Map.Error) -> Memory.Address {
            guard length.underlying.rawValue > 0 else {
                throw .invalid(.length)
            }

            let allocationType = DWORD(MEM_COMMIT | MEM_RESERVE)
            let result = unsafe VirtualAlloc(
                addr?.mutablePointer,
                SIZE_T(length.underlying.rawValue),
                allocationType,
                protection.windowsVirtualProtect
            )

            guard let result else {
                throw .map(Error_Primitives.Error.captureLastError())
            }

            return unsafe Memory.Address(result)
        }

        /// Unmaps a previously mapped region.
        ///
        /// - Parameters:
        ///   - addr: The base address of the mapping.
        ///   - length: The length of the mapping (ignored on Windows for file mappings).
        ///   - isAnonymous: True if this was an anonymous mapping (VirtualAlloc).
        /// - Throws: `Error.unmap` on failure.
        public static func unmap(
            addr: Memory.Address,
            length: Memory.Address.Count,
            isAnonymous: Bool = false
        ) throws(Memory.Map.Error) {
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
            addr: Memory.Address,
            length: Memory.Address.Count
        ) throws(Memory.Map.Error) {
            guard unsafe FlushViewOfFile(addr.pointer, SIZE_T(length.underlying.rawValue)) else {
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
            addr: Memory.Address,
            length: Memory.Address.Count,
            protection: Protection
        ) throws(Memory.Map.Error) {
            var oldProtect: DWORD = 0
            guard
                unsafe VirtualProtect(
                    addr.mutablePointer,
                    SIZE_T(length.underlying.rawValue),
                    protection.windowsVirtualProtect,
                    &oldProtect
                )
            else {
                throw .protect(Error_Primitives.Error.captureLastError())
            }
        }
    }

#endif
