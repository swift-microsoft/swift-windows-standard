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

// MARK: - Windows Memory Locking

extension Memory.Lock {
    /// Locks a region of memory into physical RAM.
    ///
    /// Prevents the system from paging out the memory to disk.
    /// Uses `VirtualLock` on Windows.
    ///
    /// - Parameters:
    ///   - address: The base address of the region.
    ///   - length: The number of bytes to lock.
    /// - Throws: `Memory.Lock.Error` on failure.
    @unsafe
    public static func lock(
        address: UnsafeRawPointer,
        length: Windows.`32`.Kernel.File.Size
    ) throws(Memory.Lock.Error) {
        guard VirtualLock(UnsafeMutableRawPointer(mutating: address), SIZE_T(length.rawValue)) else {
            throw .lock(Error_Primitives.Error.captureLastError())
        }
    }

    /// Unlocks a region of memory.
    ///
    /// Allows the system to page out the memory to disk.
    /// Uses `VirtualUnlock` on Windows.
    ///
    /// - Parameters:
    ///   - address: The base address of the region.
    ///   - length: The number of bytes to unlock.
    /// - Throws: `Memory.Lock.Error` on failure.
    @unsafe
    public static func unlock(
        address: UnsafeRawPointer,
        length: Windows.`32`.Kernel.File.Size
    ) throws(Memory.Lock.Error) {
        guard VirtualUnlock(UnsafeMutableRawPointer(mutating: address), SIZE_T(length.rawValue)) else {
            throw .unlock(Error_Primitives.Error.captureLastError())
        }
    }
}

#endif
