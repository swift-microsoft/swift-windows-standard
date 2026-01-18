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

// MARK: - Windows DeleteFileW syscall

extension Windows.Kernel.File.Delete {
    /// Deletes a file.
    ///
    /// On Windows, the file may not be immediately deleted if other processes
    /// have the file open. The file will be deleted when the last handle is closed.
    ///
    /// - Parameter path: The path of the file to delete.
    /// - Throws: `Kernel.File.Delete.Error` on failure.
    public static func delete(
        path: borrowing Kernel.Path
    ) throws(Kernel.File.Delete.Error) {
        try delete(unsafePath: path.unsafeCString)
    }

    /// Deletes a file using an unsafe wide string.
    ///
    /// - Parameter unsafePath: The path as a null-terminated wide string.
    /// - Throws: `Kernel.File.Delete.Error` on failure.
    public static func delete(
        unsafePath: UnsafePointer<Kernel.Path.Char>
    ) throws(Kernel.File.Delete.Error) {
        let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
        guard DeleteFileW(wpath) else {
            throw .current()
        }
    }
}

// MARK: - Error Construction

extension Kernel.File.Delete.Error {
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
        case Windows.Kernel.Error.Code.Access.sharingViolation:
            return .busy
        default:
            return .platform(Kernel.Error(code: code))
        }
    }
}

#endif
