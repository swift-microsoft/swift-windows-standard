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

// MARK: - Windows CreateDirectoryW syscall

extension Windows.Kernel.Mkdir {
    /// Creates a directory at the specified path.
    ///
    /// - Parameters:
    ///   - path: The path where the directory should be created.
    ///   - permissions: POSIX permissions (ignored on Windows, uses default security).
    /// - Throws: `Kernel.Mkdir.Error` on failure.
    public static func mkdir(
        path: borrowing Kernel.Path,
        permissions: Kernel.File.Permissions = .directoryDefault
    ) throws(Kernel.Mkdir.Error) {
        try mkdir(unsafePath: path.unsafeCString, permissions: permissions)
    }

    /// Creates a directory at the specified path using an unsafe wide string.
    ///
    /// - Parameters:
    ///   - unsafePath: The path as a null-terminated wide string.
    ///   - permissions: POSIX permissions (ignored on Windows).
    /// - Throws: `Kernel.Mkdir.Error` on failure.
    public static func mkdir(
        unsafePath: UnsafePointer<Kernel.Path.Char>,
        permissions: Kernel.File.Permissions = .directoryDefault
    ) throws(Kernel.Mkdir.Error) {
        let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
        guard CreateDirectoryW(wpath, nil) else {
            throw .current()
        }
    }
}

// MARK: - Error Construction

extension Kernel.Mkdir.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        let code = Windows.Kernel.Error.captureLastError()
        guard let win32Code = code.win32 else {
            return .platform(Kernel.Error(code: code))
        }

        switch win32Code {
        case Windows.Kernel.Error.Code.File.pathNotFound:
            return .notFound
        case Windows.Kernel.Error.Code.Access.denied:
            return .permission
        case Windows.Kernel.Error.Code.File.exists,
             Windows.Kernel.Error.Code.File.alreadyExists:
            return .exists
        case Windows.Kernel.Error.Code.Storage.diskFull,
             Windows.Kernel.Error.Code.Storage.handleDiskFull:
            return .noSpace
        default:
            return .platform(Kernel.Error(code: code))
        }
    }
}

#endif
