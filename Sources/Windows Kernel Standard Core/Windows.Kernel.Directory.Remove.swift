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
@_spi(Syscall) public import Kernel_Clock_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
public import WinSDK

// MARK: - Windows RemoveDirectoryW syscall

extension Windows.Kernel.Directory.Remove {
    /// Removes an empty directory.
    ///
    /// - Parameter path: The path of the directory to remove.
    /// - Throws: `Kernel.Directory.Remove.Error` on failure.
    public static func remove(
        path: borrowing Kernel.Path
    ) throws(Kernel.Directory.Remove.Error) {
        try path.withUnsafeCString { ptr throws(Kernel.Directory.Remove.Error) in
            try remove(unsafePath: ptr)
        }
    }

    /// Removes an empty directory using an unsafe wide string.
    ///
    /// - Parameter unsafePath: The path as a null-terminated wide string.
    /// - Throws: `Kernel.Directory.Remove.Error` on failure.
    public static func remove(
        unsafePath: UnsafePointer<Path.Char>
    ) throws(Kernel.Directory.Remove.Error) {
        let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
        guard RemoveDirectoryW(wpath) else {
            throw .current()
        }
    }
}

// MARK: - Error Construction

extension Kernel.Directory.Remove.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        let code = Windows.Kernel.Error.captureLastError()
        guard let win32Code = code.win32 else {
            return .platform(Kernel.Error(code: code))
        }

        switch win32Code {
        case Windows.Kernel.Error.Code.File.notFound,
             Windows.Kernel.Error.Code.File.pathNotFound:
            return .notFound
        case Windows.Kernel.Error.Code.Access.denied:
            return .permission
        case Windows.Kernel.Error.Code.Directory.notEmpty:
            return .notEmpty
        case Windows.Kernel.Error.Code.Access.sharingViolation:
            return .busy
        default:
            return .platform(Kernel.Error(code: code))
        }
    }
}

#endif
