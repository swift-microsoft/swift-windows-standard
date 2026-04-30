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
@_spi(Syscall) public import Error_Primitives
@_spi(Syscall) public import Memory_Primitives
public import WinSDK

// MARK: - Windows Shared Memory

extension Memory {
    /// Namespace for shared memory operations.
    ///
    /// Windows shared memory is implemented using named file mappings backed
    /// by the system paging file. This is the equivalent of POSIX `shm_open`.
    public enum Shared {}
}

// MARK: - Create/Open Shared Memory

extension Memory.Shared {
    /// Creates or opens a named shared memory object.
    ///
    /// This creates a file mapping backed by the system paging file,
    /// equivalent to POSIX `shm_open` + `ftruncate` + `mmap`.
    ///
    /// - Parameters:
    ///   - name: The name of the shared memory object (e.g., "Local\\MySharedMem").
    ///   - size: The size of the shared memory region in bytes.
    ///   - protection: Memory protection flags.
    /// - Returns: Handle to the file mapping object.
    /// - Throws: `Memory.Error` on failure.
    public static func create(
        name: UnsafePointer<WCHAR>,
        size: UInt64,
        protection: Memory.Map.Protection = .readWrite
    ) throws(Memory.Error) -> HANDLE {
        let sizeHigh = DWORD(size >> 32)
        let sizeLow = DWORD(size & 0xFFFFFFFF)

        let handle = CreateFileMappingW(
            INVALID_HANDLE_VALUE,  // Use paging file
            nil,                    // Default security
            protection.rawValue,
            sizeHigh,
            sizeLow,
            name
        )

        guard let handle, handle != INVALID_HANDLE_VALUE else {
            throw .map(.create(Error_Primitives.Error.captureLastError()))
        }

        return handle
    }

    /// Opens an existing named shared memory object.
    ///
    /// - Parameters:
    ///   - name: The name of the shared memory object.
    ///   - access: Desired access (FILE_MAP_READ, FILE_MAP_WRITE, FILE_MAP_ALL_ACCESS).
    /// - Returns: Handle to the file mapping object.
    /// - Throws: `Memory.Error` on failure.
    public static func open(
        name: UnsafePointer<WCHAR>,
        access: DWORD = DWORD(FILE_MAP_ALL_ACCESS)
    ) throws(Memory.Error) -> HANDLE {
        let handle = OpenFileMappingW(
            access,
            false,  // Don't inherit handle
            name
        )

        guard let handle, handle != INVALID_HANDLE_VALUE else {
            throw .map(.open(Error_Primitives.Error.captureLastError()))
        }

        return handle
    }

    /// Closes a shared memory handle.
    ///
    /// - Parameter handle: The file mapping handle.
    @inlinable
    public static func close(_ handle: HANDLE) {
        _ = CloseHandle(handle)
    }
}

// MARK: - Map/Unmap Shared Memory

extension Memory.Shared {
    /// Maps a view of the shared memory into the process address space.
    ///
    /// - Parameters:
    ///   - handle: The file mapping handle.
    ///   - access: Desired access (FILE_MAP_READ, FILE_MAP_WRITE, FILE_MAP_ALL_ACCESS).
    ///   - offset: Offset into the shared memory to start the view.
    ///   - size: Size of the view (0 for entire mapping from offset).
    /// - Returns: Pointer to the mapped view.
    /// - Throws: `Memory.Error` on failure.
    public static func map(
        _ handle: HANDLE,
        access: DWORD = DWORD(FILE_MAP_ALL_ACCESS),
        offset: UInt64 = 0,
        size: Int = 0
    ) throws(Memory.Error) -> UnsafeMutableRawPointer {
        let offsetHigh = DWORD(offset >> 32)
        let offsetLow = DWORD(offset & 0xFFFFFFFF)

        guard let ptr = MapViewOfFile(
            handle,
            access,
            offsetHigh,
            offsetLow,
            SIZE_T(size)
        ) else {
            throw .map(.mapView(Error_Primitives.Error.captureLastError()))
        }

        return ptr
    }

    /// Unmaps a view of shared memory.
    ///
    /// - Parameter address: The base address of the mapped view.
    /// - Returns: True on success, false on failure.
    @inlinable
    @discardableResult
    public static func unmap(_ address: UnsafeMutableRawPointer) -> Bool {
        UnmapViewOfFile(address)
    }
}

// MARK: - Access Flags

extension Memory.Shared {
    /// Shared memory access flags.
    public struct Access: OptionSet, Sendable {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        /// Read access.
        public static let read = Access(rawValue: UInt32(FILE_MAP_READ))

        /// Write access.
        public static let write = Access(rawValue: UInt32(FILE_MAP_WRITE))

        /// Read and write access.
        public static let readWrite: Access = [.read, .write]

        /// All access (read, write, copy).
        public static let all = Access(rawValue: UInt32(FILE_MAP_ALL_ACCESS))

        /// Copy-on-write access.
        public static let copy = Access(rawValue: UInt32(FILE_MAP_COPY))

        /// Execute access (requires PAGE_EXECUTE_* protection).
        public static let execute = Access(rawValue: UInt32(FILE_MAP_EXECUTE))
    }
}

// MARK: - Error Extension

extension Memory.Map.Error {
    /// Error from file mapping creation.
    static func create(_ code: Error_Primitives.Error.Code) -> Self {
        Self(code: code)
    }

    /// Error from opening existing file mapping.
    static func open(_ code: Error_Primitives.Error.Code) -> Self {
        Self(code: code)
    }

    /// Error from mapping a view.
    static func mapView(_ code: Error_Primitives.Error.Code) -> Self {
        Self(code: code)
    }
}

#endif
