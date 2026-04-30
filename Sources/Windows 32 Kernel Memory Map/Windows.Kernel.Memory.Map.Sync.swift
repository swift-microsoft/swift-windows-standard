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

// MARK: - Windows Memory Map Sync

extension Memory.Map {
    /// Flushes a range of a mapped view to disk.
    ///
    /// This is the Windows equivalent of POSIX `msync()`.
    ///
    /// - Parameters:
    ///   - address: Start address of the range to flush.
    ///   - size: Number of bytes to flush. If 0, flushes from address to end of mapping.
    /// - Throws: `Memory.Map.Error` on failure.
    public static func sync(
        _ address: Memory.Address,
        size: Int
    ) throws(Memory.Map.Error) {
        guard unsafe FlushViewOfFile(address.pointer, SIZE_T(size)) else {
            throw .sync(Error_Primitives.Error.captureLastError())
        }
    }

    /// Flushes an entire mapped view to disk.
    ///
    /// - Parameter buffer: The mapped buffer to flush.
    /// - Throws: `Memory.Map.Error` on failure.
    public static func sync(
        _ buffer: UnsafeRawBufferPointer
    ) throws(Memory.Map.Error) {
        guard let baseAddress = buffer.baseAddress else { return }
        guard unsafe FlushViewOfFile(baseAddress, SIZE_T(buffer.count)) else {
            throw .sync(Error_Primitives.Error.captureLastError())
        }
    }

    /// Flushes a mutable mapped view to disk.
    ///
    /// - Parameter buffer: The mapped buffer to flush.
    /// - Throws: `Memory.Map.Error` on failure.
    public static func sync(
        _ buffer: UnsafeMutableRawBufferPointer
    ) throws(Memory.Map.Error) {
        guard let baseAddress = buffer.baseAddress else { return }
        guard unsafe FlushViewOfFile(baseAddress, SIZE_T(buffer.count)) else {
            throw .sync(Error_Primitives.Error.captureLastError())
        }
    }
}

// MARK: - Sync Error Extension

extension Memory.Map.Error {
    /// Creates an error from a sync failure.
    static func sync(_ code: Error_Primitives.Error.Code) -> Self {
        Self(code: code)
    }
}

#endif
