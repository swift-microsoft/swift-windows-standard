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
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
public import WinSDK

// MARK: - Windows FlushFileBuffers syscall

extension Windows.Kernel.File.Flush {
    /// Flushes file buffers to disk.
    ///
    /// Ensures that all buffered data for the specified file has been written
    /// to the underlying storage device.
    ///
    /// - Parameter descriptor: The file descriptor to flush.
    /// - Throws: `Kernel.File.Flush.Error` on failure.
    public static func flush(_ descriptor: Kernel.Descriptor) throws(Kernel.File.Flush.Error) {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }

        guard FlushFileBuffers(descriptor.handle) else {
            throw .current()
        }
    }

    /// Flushes file data to disk (same as flush on Windows).
    ///
    /// On Windows, there is no distinction between flushing data and metadata.
    /// Both operations flush all data and metadata.
    ///
    /// - Parameter descriptor: The file descriptor to flush.
    /// - Throws: `Kernel.File.Flush.Error` on failure.
    public static func flushData(_ descriptor: Kernel.Descriptor) throws(Kernel.File.Flush.Error) {
        try flush(descriptor)
    }
}

// MARK: - Error Construction

extension Kernel.File.Flush.Error {
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
