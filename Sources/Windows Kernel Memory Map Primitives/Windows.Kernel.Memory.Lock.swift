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
@_spi(Syscall) public import Kernel_Primitives
public import WinSDK

// MARK: - Windows Memory Locking

extension Windows.Kernel.Memory.Lock {
    /// Locks a region of memory into physical RAM.
    ///
    /// Prevents the system from paging out the memory to disk.
    /// Uses `VirtualLock` on Windows.
    ///
    /// - Parameters:
    ///   - address: The base address of the region.
    ///   - length: The number of bytes to lock.
    /// - Throws: `Kernel.Memory.Lock.Error` on failure.
    @unsafe
    public static func lock(
        address: UnsafeRawPointer,
        length: Kernel.File.Size
    ) throws(Kernel.Memory.Lock.Error) {
        guard VirtualLock(UnsafeMutableRawPointer(mutating: address), SIZE_T(length.rawValue)) else {
            throw .lock(Windows.Kernel.Error.captureLastError())
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
    /// - Throws: `Kernel.Memory.Lock.Error` on failure.
    @unsafe
    public static func unlock(
        address: UnsafeRawPointer,
        length: Kernel.File.Size
    ) throws(Kernel.Memory.Lock.Error) {
        guard VirtualUnlock(UnsafeMutableRawPointer(mutating: address), SIZE_T(length.rawValue)) else {
            throw .unlock(Windows.Kernel.Error.captureLastError())
        }
    }
}

#endif
