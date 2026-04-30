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
@_spi(Syscall) public import Kernel_IO_Primitives
public import WinSDK

// MARK: - Windows ReadFile syscall (raw @_spi(Syscall))

extension Windows.Kernel.IO.Read {
    /// Reads bytes from a raw Windows HANDLE bit pattern.
    ///
    /// Spec-literal raw `ReadFile`. The typed L2 convenience
    /// (`Windows.Kernel.IO.Read.read(_:into:)` taking `Windows.Kernel.Descriptor`)
    /// delegates to this raw SPI internally via `descriptor._rawValue` after
    /// a fast-fail validity check.
    ///
    /// This is the synchronous read variant for non-overlapped handles. For
    /// async I/O with completion ports, use the IOCP-specific read functions.
    ///
    /// - Parameters:
    ///   - handle: HANDLE bit pattern.
    ///   - buffer: The buffer to read into.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: ``Kernel/IO/Read/Error`` on failure.
    @_spi(Syscall)
    public static func read(
        _ handle: UInt,
        into buffer: UnsafeMutableRawBufferPointer
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }
        guard let pointer = UnsafeMutableRawPointer(bitPattern: handle) else {
            throw .handle(.invalid)
        }

        var bytesRead: DWORD = 0
        let success = ReadFile(
            pointer,
            baseAddress,
            DWORD(buffer.count),
            &bytesRead,
            nil  // No overlapped for synchronous
        )

        if !success {
            let error = GetLastError()
            // ERROR_HANDLE_EOF is not an error, just EOF
            if error == Error_Primitives.Error.Code.IO.handleEOF {
                return 0
            }
            throw .current()
        }

        return Int(bytesRead)
    }

    /// Reads bytes from a raw Windows HANDLE bit pattern at a specific offset.
    ///
    /// Spec-literal raw `SetFilePointerEx + ReadFile`. The typed L2
    /// convenience (`Windows.Kernel.IO.Read.pread(_:into:at:)` taking
    /// `Windows.Kernel.Descriptor`) delegates to this raw SPI internally via
    /// `descriptor._rawValue` after a fast-fail validity check.
    ///
    /// This does NOT modify the file pointer atomically on Windows (unlike
    /// POSIX pread). Use external synchronization if needed.
    ///
    /// - Parameters:
    ///   - handle: HANDLE bit pattern.
    ///   - buffer: The buffer to read into.
    ///   - offset: The file offset to read from.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: ``Kernel/IO/Read/Error`` on failure.
    @_spi(Syscall)
    public static func pread(
        _ handle: UInt,
        into buffer: UnsafeMutableRawBufferPointer,
        at offset: Windows.Kernel.File.Offset
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }
        guard let pointer = UnsafeMutableRawPointer(bitPattern: handle) else {
            throw .handle(.invalid)
        }

        // Save current position
        var currentPos: LARGE_INTEGER = LARGE_INTEGER()
        var zero: LARGE_INTEGER = LARGE_INTEGER()
        zero.QuadPart = 0
        guard SetFilePointerEx(pointer, zero, &currentPos, DWORD(FILE_CURRENT)) else {
            throw .current()
        }

        // Seek to offset
        var targetPos: LARGE_INTEGER = LARGE_INTEGER()
        targetPos.QuadPart = offset.rawValue
        guard SetFilePointerEx(pointer, targetPos, nil, DWORD(FILE_BEGIN)) else {
            throw .current()
        }

        // Read
        var bytesRead: DWORD = 0
        let readSuccess = ReadFile(
            pointer,
            baseAddress,
            DWORD(buffer.count),
            &bytesRead,
            nil
        )

        // Restore position regardless of read result
        _ = SetFilePointerEx(pointer, currentPos, nil, DWORD(FILE_BEGIN))

        if !readSuccess {
            let error = GetLastError()
            if error == Error_Primitives.Error.Code.IO.handleEOF {
                return 0
            }
            throw .current()
        }

        return Int(bytesRead)
    }
}

// MARK: - Typed Convenience

extension Windows.Kernel.IO.Read {
    /// Reads bytes from a file descriptor.
    ///
    /// Typed L2 form. Delegates to the raw `read(_:into:)` SPI via
    /// `descriptor._rawValue` after a fast-fail validity check.
    ///
    /// This is the synchronous read variant for non-overlapped handles. For
    /// async I/O with completion ports, use the IOCP-specific read functions.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to read from.
    ///   - buffer: The buffer to read into.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: ``Kernel/IO/Read/Error`` on failure.
    public static func read(
        _ descriptor: Windows.Kernel.Descriptor,
        into buffer: UnsafeMutableRawBufferPointer
    ) throws(Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        return try read(descriptor._rawValue, into: buffer)
    }

    /// Reads bytes from a file descriptor at a specific offset.
    ///
    /// Typed L2 form. Delegates to the raw `pread(_:into:at:)` SPI via
    /// `descriptor._rawValue` after a fast-fail validity check.
    ///
    /// Uses SetFilePointerEx + ReadFile for positioned reads. This does NOT
    /// modify the file pointer atomically on Windows (unlike POSIX pread).
    /// Use external synchronization if needed.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to read from.
    ///   - buffer: The buffer to read into.
    ///   - offset: The file offset to read from.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: ``Kernel/IO/Read/Error`` on failure.
    public static func pread(
        _ descriptor: Windows.Kernel.Descriptor,
        into buffer: UnsafeMutableRawBufferPointer,
        at offset: Windows.Kernel.File.Offset
    ) throws(Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        return try pread(descriptor._rawValue, into: buffer, at: offset)
    }
}

// MARK: - Span Adapters

extension Windows.Kernel.IO.Read {
    /// Reads bytes from a file descriptor into a mutable span.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to read from.
    ///   - span: The mutable span to read into.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Windows.Kernel.IO.Read.Error` on failure.
    @inlinable
    public static func read(
        _ descriptor: Windows.Kernel.Descriptor,
        into span: inout MutableSpan<UInt8>
    ) throws(Error) -> Int {
        try span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(Error) -> Int in
            try read(descriptor, into: buffer)
        }
    }

    /// Reads bytes from a file descriptor at a specific offset into a mutable span.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to read from.
    ///   - span: The mutable span to read into.
    ///   - offset: The file offset to read from.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Windows.Kernel.IO.Read.Error` on failure.
    @inlinable
    public static func pread(
        _ descriptor: Windows.Kernel.Descriptor,
        into span: inout MutableSpan<UInt8>,
        at offset: Windows.Kernel.File.Offset
    ) throws(Error) -> Int {
        try span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(Error) -> Int in
            try pread(descriptor, into: buffer, at: offset)
        }
    }
}

// MARK: - Error Type Alias

extension Windows.Kernel.IO.Read {
    public typealias Error = Windows.Kernel.IO.Read.Error
}

// MARK: - Error Construction

extension Windows.Kernel.IO.Read.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        Self(code: Error_Primitives.Error.captureLastError())
    }
}

#endif
