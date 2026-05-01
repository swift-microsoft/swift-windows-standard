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
public import Binary_Primitives

// MARK: - Windows Virtual Memory Allocation

extension Memory.Allocation {
    /// Allocates virtual memory.
    ///
    /// - Parameters:
    ///   - addr: Suggested address, or `nil` for system to choose.
    ///   - size: Number of bytes to allocate.
    ///   - protection: Memory protection flags.
    /// - Returns: Pointer to the allocated memory.
    /// - Throws: `Memory.Allocation.Error` on failure.
    public static func allocate(
        addr: Memory.Address? = nil,
        size: Int,
        protection: Memory.Map.Protection
    ) throws(Error) -> Memory.Address {
        guard size > 0 else {
            throw .invalidSize
        }

        let result = unsafe VirtualAlloc(
            addr?.mutablePointer,
            SIZE_T(size),
            DWORD(MEM_COMMIT | MEM_RESERVE),
            protection.windowsVirtualProtect
        )

        guard let result else {
            throw .current()
        }

        return unsafe Memory.Address(result)
    }

    /// Frees virtual memory.
    ///
    /// - Parameter addr: The base address of the allocation.
    /// - Throws: `Memory.Allocation.Error` on failure.
    public static func free(
        addr: Memory.Address
    ) throws(Error) {
        guard unsafe VirtualFree(addr.mutablePointer, 0, DWORD(MEM_RELEASE)) else {
            throw .free(Error_Primitives.Error.captureLastError())
        }
    }

    /// Allocates aligned virtual memory.
    ///
    /// On Windows, VirtualAlloc always returns page-aligned memory (typically 4KB).
    ///
    /// - Parameters:
    ///   - size: Number of bytes to allocate.
    ///   - alignment: Required alignment (must be a power of 2).
    ///   - protection: Memory protection flags.
    /// - Returns: Pointer to the aligned memory.
    /// - Throws: `Memory.Allocation.Error` on failure.
    public static func allocateAligned(
        size: Int,
        alignment: Int,
        protection: Memory.Map.Protection
    ) throws(Error) -> Memory.Address {
        // Windows VirtualAlloc returns page-aligned memory
        // For larger alignments, we need to allocate extra and align manually
        let pageSize = Int(systemPageSize())

        if alignment <= pageSize {
            return try allocate(size: size, protection: protection)
        }

        // For larger alignments, allocate extra space
        let extraSize = size + alignment - pageSize
        let baseAddr = try allocate(size: extraSize, protection: protection)

        // Calculate aligned address within the allocation
        let baseValue = Int(bitPattern: baseAddr.pointer)
        let alignedValue = (baseValue + alignment - 1) & ~(alignment - 1)

        // If already aligned, return as-is
        if baseValue == alignedValue {
            return baseAddr
        }

        // Otherwise, free and re-allocate at aligned address
        // Note: This is a simplification. A more robust implementation
        // would use VirtualAlloc with MEM_RESERVE, then MEM_COMMIT
        // at the aligned address.
        try? free(addr: baseAddr)
        throw .alignmentNotSupported
    }

    /// Returns the system page size.
    ///
    /// - Returns: The system memory page size in bytes.
    public static func systemPageSize() -> UInt {
        var sysInfo = SYSTEM_INFO()
        GetSystemInfo(&sysInfo)
        return UInt(sysInfo.dwPageSize)
    }

    /// The system's allocation granularity.
    ///
    /// On Windows, this is typically 64KB, larger than page size.
    /// Use this for memory mapping offset alignment.
    public static var system: Memory.Allocation.Granularity {
        var sysInfo = SYSTEM_INFO()
        GetSystemInfo(&sysInfo)
        let granularity = Int(sysInfo.dwAllocationGranularity)
        // Safe: allocation granularity is always a power of 2
        return Memory.Allocation.Granularity(try! Memory.Alignment(granularity))
    }
}

// MARK: - Error Type

extension Memory.Allocation {
    /// Errors from memory allocation operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Invalid size requested.
        case invalidSize

        /// Alignment not supported.
        case alignmentNotSupported

        /// Allocation failed with platform error.
        case allocate(Error_Primitives.Error.Code)

        /// Free failed with platform error.
        case free(Error_Primitives.Error.Code)

        /// Platform error.
        case platform(Error_Primitives.Error)
    }
}

// MARK: - Error Construction

extension Memory.Allocation.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        .allocate(Error_Primitives.Error.captureLastError())
    }
}

#endif
