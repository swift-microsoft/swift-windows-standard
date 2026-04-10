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
@_spi(Syscall) public import Kernel_IO_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
public import WinSDK

// MARK: - Windows WriteFile syscall (synchronous)

extension Windows.Kernel.IO.Write {
    /// Writes bytes to a file descriptor at the current file offset.
    ///
    /// This is the synchronous write variant for non-overlapped handles.
    /// For async I/O with completion ports, use the IOCP-specific write functions.
    ///
    /// ## Threading
    /// This call blocks until at least one byte is written or an error occurs.
    /// The file offset is advanced by the number of bytes written. Concurrent
    /// sequential writes require external synchronization.
    ///
    /// ## Partial Writes
    /// May return fewer bytes than `buffer.count`. This is not an error—loop until
    /// all data is written. Returns 0 only for zero-length buffers.
    ///
    /// ## Errors
    /// - ``Error/handle(_:)``: Invalid descriptor
    /// - ``Error/io(_:)``: Physical I/O error
    /// - ``Error/space(_:)``: Disk full
    /// - ``Error/blocking(_:)``: Non-blocking descriptor would block
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - buffer: The buffer to write from.
    /// - Returns: Number of bytes written (may be less than `buffer.count`).
    /// - Throws: ``Kernel/IO/Write/Error`` on failure.
    public static func write(
        _ descriptor: Kernel.Descriptor,
        from buffer: UnsafeRawBufferPointer
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }

        var bytesWritten: DWORD = 0
        let success = WriteFile(
            descriptor.handle,
            baseAddress,
            DWORD(buffer.count),
            &bytesWritten,
            nil  // No overlapped for synchronous
        )

        guard success else {
            throw .current()
        }

        return Int(bytesWritten)
    }

    /// Writes bytes to a file descriptor at a specific offset without changing the file position.
    ///
    /// Uses SetFilePointerEx + WriteFile for positioned writes.
    /// This does NOT modify the file pointer atomically on Windows
    /// (unlike POSIX pwrite). Use external synchronization if needed.
    ///
    /// ## Threading
    /// This call blocks until at least one byte is written or an error occurs.
    /// The original file offset is restored after the write.
    ///
    /// ## Partial Writes
    /// May return fewer bytes than `buffer.count`. This is not an error—loop until
    /// all data is written, adjusting the offset accordingly.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - buffer: The buffer to write from.
    ///   - offset: The file offset to write at.
    /// - Returns: Number of bytes written (may be less than `buffer.count`).
    /// - Throws: ``Kernel/IO/Write/Error`` on failure.
    public static func pwrite(
        _ descriptor: Kernel.Descriptor,
        from buffer: UnsafeRawBufferPointer,
        at offset: Kernel.File.Offset
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }

        // Save current position
        var currentPos: LARGE_INTEGER = LARGE_INTEGER()
        var zero: LARGE_INTEGER = LARGE_INTEGER()
        zero.QuadPart = 0
        guard SetFilePointerEx(descriptor.handle, zero, &currentPos, DWORD(FILE_CURRENT)) else {
            throw .current()
        }

        // Seek to offset
        var targetPos: LARGE_INTEGER = LARGE_INTEGER()
        targetPos.QuadPart = offset.rawValue
        guard SetFilePointerEx(descriptor.handle, targetPos, nil, DWORD(FILE_BEGIN)) else {
            throw .current()
        }

        // Write
        var bytesWritten: DWORD = 0
        let writeSuccess = WriteFile(
            descriptor.handle,
            baseAddress,
            DWORD(buffer.count),
            &bytesWritten,
            nil
        )

        // Restore position regardless of write result
        _ = SetFilePointerEx(descriptor.handle, currentPos, nil, DWORD(FILE_BEGIN))

        guard writeSuccess else {
            throw .current()
        }

        return Int(bytesWritten)
    }
}

// MARK: - Span Adapters

extension Windows.Kernel.IO.Write {
    /// Writes bytes from a span to a file descriptor.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - span: The span containing bytes to write.
    /// - Returns: Number of bytes written.
    /// - Throws: `Kernel.IO.Write.Error` on failure.
    @inlinable
    public static func write(
        _ descriptor: Kernel.Descriptor,
        from span: Span<UInt8>
    ) throws(Error) -> Int {
        try span.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(Error) -> Int in
            try write(descriptor, from: buffer)
        }
    }

    /// Writes bytes from a span to a file descriptor at a specific offset.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - span: The span containing bytes to write.
    ///   - offset: The file offset to write at.
    /// - Returns: Number of bytes written.
    /// - Throws: `Kernel.IO.Write.Error` on failure.
    @inlinable
    public static func pwrite(
        _ descriptor: Kernel.Descriptor,
        from span: Span<UInt8>,
        at offset: Kernel.File.Offset
    ) throws(Error) -> Int {
        try span.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(Error) -> Int in
            try pwrite(descriptor, from: buffer, at: offset)
        }
    }
}

// MARK: - Error Type Alias

extension Windows.Kernel.IO.Write {
    public typealias Error = Kernel.IO.Write.Error
}

// MARK: - Error Construction

extension Kernel.IO.Write.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        Self(code: Windows.Kernel.Error.captureLastError())
    }
}

#endif
