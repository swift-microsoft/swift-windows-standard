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
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Memory_Primitives
public import WinSDK

// MARK: - Windows Anonymous Memory Mapping

extension Memory.Map.Anonymous {
    /// Creates an anonymous memory mapping.
    ///
    /// Anonymous mappings are not backed by any file. They are initialized to zero.
    /// On Windows, this uses `VirtualAlloc` with `MEM_COMMIT | MEM_RESERVE`.
    ///
    /// - Parameters:
    ///   - length: Number of bytes to map (must be > 0).
    ///   - protection: Memory protection flags (default: read/write).
    /// - Returns: A region describing the mapped memory.
    /// - Throws: `Memory.Map.Error` on failure.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create an anonymous mapping
    /// let region = try Memory.Map.Anonymous.map(length: 4096)
    /// defer { try? Memory.Map.unmap(addr: region.base, length: region.length, isAnonymous: true) }
    ///
    /// // Write to the memory
    /// region.base.mutablePointer.storeBytes(of: 42, as: Int.self)
    /// ```
    public static func map(
        length: Kernel.File.Size,
        protection: Memory.Map.Protection = [.read, .write]
    ) throws(Memory.Map.Error) -> Memory.Map.Region {
        let addr = try Memory.Map.mapAnonymous(
            length: length,
            protection: protection
        )

        return Memory.Map.Region(base: addr, length: length)
    }

    /// Creates an anonymous memory mapping at a specific address.
    ///
    /// - Parameters:
    ///   - addr: Suggested address for the mapping.
    ///   - length: Number of bytes to map.
    ///   - protection: Memory protection flags.
    /// - Returns: A region describing the mapped memory.
    /// - Throws: `Memory.Map.Error` on failure.
    public static func map(
        addr: Memory.Address,
        length: Kernel.File.Size,
        protection: Memory.Map.Protection
    ) throws(Memory.Map.Error) -> Memory.Map.Region {
        let mappedAddr = try Memory.Map.mapAnonymous(
            addr: addr,
            length: length,
            protection: protection
        )

        return Memory.Map.Region(base: mappedAddr, length: length)
    }
}

#endif
