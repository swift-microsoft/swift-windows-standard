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
@_spi(Syscall) public import Kernel_Primitives_Core
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
@_spi(Syscall) public import Kernel_Thread_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
public import WinSDK

// MARK: - Windows Pipe Operations

extension Windows.Kernel.Pipe {
    /// A pair of pipe endpoints (read and write).
    public struct Pair {
        /// The read end of the pipe.
        public let read: Kernel.Descriptor
        /// The write end of the pipe.
        public let write: Kernel.Descriptor
    }

    /// Creates an anonymous pipe.
    ///
    /// - Parameter bufferSize: Suggested buffer size (0 for default).
    /// - Returns: A pair of descriptors (read, write).
    /// - Throws: `Kernel.Pipe.Error` on failure.
    public static func create(
        bufferSize: UInt32 = 0
    ) throws(Kernel.Pipe.Error) -> Pair {
        var readHandle: HANDLE? = nil
        var writeHandle: HANDLE? = nil

        guard CreatePipe(&readHandle, &writeHandle, nil, bufferSize) else {
            throw .current()
        }

        guard let read = readHandle, let write = writeHandle else {
            throw .current()
        }

        return Pair(
            read: Kernel.Descriptor.borrowing(handle: read),
            write: Kernel.Descriptor.borrowing(handle: write)
        )
    }

    /// Creates an anonymous pipe with inheritable handles.
    ///
    /// Used when creating pipes for child process I/O redirection.
    ///
    /// - Parameters:
    ///   - bufferSize: Suggested buffer size (0 for default).
    ///   - inheritRead: Whether the read handle should be inheritable.
    ///   - inheritWrite: Whether the write handle should be inheritable.
    /// - Returns: A pair of descriptors (read, write).
    /// - Throws: `Kernel.Pipe.Error` on failure.
    public static func create(
        bufferSize: UInt32 = 0,
        inheritRead: Bool,
        inheritWrite: Bool
    ) throws(Kernel.Pipe.Error) -> Pair {
        var securityAttributes = SECURITY_ATTRIBUTES()
        securityAttributes.nLength = DWORD(MemoryLayout<SECURITY_ATTRIBUTES>.size)
        securityAttributes.bInheritHandle = true
        securityAttributes.lpSecurityDescriptor = nil

        var readHandle: HANDLE? = nil
        var writeHandle: HANDLE? = nil

        guard CreatePipe(&readHandle, &writeHandle, &securityAttributes, bufferSize) else {
            throw .current()
        }

        guard var read = readHandle, var write = writeHandle else {
            throw .current()
        }

        // Make handles non-inheritable as requested
        if !inheritRead {
            let success = SetHandleInformation(read, DWORD(HANDLE_FLAG_INHERIT), 0)
            if !success {
                _ = CloseHandle(read)
                _ = CloseHandle(write)
                throw .current()
            }
        }

        if !inheritWrite {
            let success = SetHandleInformation(write, DWORD(HANDLE_FLAG_INHERIT), 0)
            if !success {
                _ = CloseHandle(read)
                _ = CloseHandle(write)
                throw .current()
            }
        }

        return Pair(
            read: Kernel.Descriptor.borrowing(handle: read),
            write: Kernel.Descriptor.borrowing(handle: write)
        )
    }
}

// MARK: - Error Construction

extension Kernel.Pipe.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        Self(code: Windows.Kernel.Error.captureLastError())
    }
}

#endif
