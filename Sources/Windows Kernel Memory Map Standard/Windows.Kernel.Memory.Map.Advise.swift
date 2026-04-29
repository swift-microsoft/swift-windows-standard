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
@_spi(Syscall) public import Memory_Primitives

// MARK: - Windows Memory Advise (No-Op)
//
// Windows does not have an equivalent to POSIX madvise().
// These functions are provided for API compatibility and are no-ops.

extension Memory.Map {
    /// Advises the kernel about expected memory access patterns.
    ///
    /// On Windows, this is a no-op since there is no equivalent to `madvise(2)`.
    /// The function is provided for cross-platform API compatibility.
    ///
    /// - Parameters:
    ///   - addr: The base address of the memory region.
    ///   - length: The length of the region in bytes.
    ///   - advice: The access pattern hint (ignored on Windows).
    @unsafe
    public static func advise(
        addr: UnsafeMutableRawPointer,
        length: Kernel.File.Size,
        advice: Memory.Map.Advice
    ) {
        // No-op on Windows
    }

    /// Advises the kernel about expected memory access patterns.
    ///
    /// On Windows, this is a no-op since there is no equivalent to `madvise(2)`.
    ///
    /// - Parameters:
    ///   - addr: The base address of the memory region.
    ///   - length: The length of the region in bytes.
    ///   - advice: The access pattern hint (ignored on Windows).
    @unsafe
    public static func advise(
        addr: UnsafeRawPointer,
        length: Kernel.File.Size,
        advice: Memory.Map.Advice
    ) {
        // No-op on Windows
    }
}

#endif
