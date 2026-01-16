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

// MARK: - Windows FlushFileBuffers syscall

extension Windows.Kernel.Sync {
    /// Flushes file buffers to disk.
    ///
    /// Ensures that all buffered data for the specified file has been written
    /// to the underlying storage device.
    ///
    /// - Parameter descriptor: The file descriptor to sync.
    /// - Throws: `Kernel.Sync.Error` on failure.
    public static func sync(_ descriptor: Kernel.Descriptor) throws(Kernel.Sync.Error) {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }

        guard FlushFileBuffers(descriptor.handle) else {
            throw .current()
        }
    }

    /// Flushes file data to disk (same as sync on Windows).
    ///
    /// On Windows, there is no distinction between `fsync` and `fdatasync`.
    /// Both operations flush all data and metadata.
    ///
    /// - Parameter descriptor: The file descriptor to sync.
    /// - Throws: `Kernel.Sync.Error` on failure.
    public static func datasync(_ descriptor: Kernel.Descriptor) throws(Kernel.Sync.Error) {
        try sync(descriptor)
    }
}

// MARK: - Error Construction

extension Kernel.Sync.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        let code = Windows.Kernel.Error.captureLastError()
        if let e = Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(e)
        }
        if let e = Kernel.IO.Error(code: code) {
            return .io(e)
        }
        return .platform(Kernel.Error(code: code))
    }
}

#endif
