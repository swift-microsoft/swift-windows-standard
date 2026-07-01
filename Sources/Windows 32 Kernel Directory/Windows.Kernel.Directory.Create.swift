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
public import WinSDK

// MARK: - Windows CreateDirectoryW syscall

extension Windows.`32`.Kernel.Directory.Create {
    /// Creates a directory at the specified path.
    ///
    /// - Parameters:
    ///   - path: The path where the directory should be created.
    ///   - permissions: POSIX permissions (ignored on Windows, uses default security).
    /// - Throws: `Windows.`32`.Kernel.Directory.Create.Error` on failure.
    public static func create(
        path: borrowing Path,
        permissions: Windows.`32`.Kernel.File.Permissions = .directoryDefault
    ) throws(Windows.`32`.Kernel.Directory.Create.Error) {
        try unsafe path.view.withUnsafePointer { ptr throws(Windows.`32`.Kernel.Directory.Create.Error) in
            try create(unsafePath: ptr, permissions: permissions)
        }
    }

    /// Creates a directory at the specified path using an unsafe wide string.
    ///
    /// - Parameters:
    ///   - unsafePath: The path as a null-terminated wide string.
    ///   - permissions: POSIX permissions (ignored on Windows).
    /// - Throws: `Windows.`32`.Kernel.Directory.Create.Error` on failure.
    public static func create(
        unsafePath: UnsafePointer<Path.Char>,
        permissions: Windows.`32`.Kernel.File.Permissions = .directoryDefault
    ) throws(Windows.`32`.Kernel.Directory.Create.Error) {
        let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
        guard CreateDirectoryW(wpath, nil) else {
            throw .current()
        }
    }
}

// MARK: - Error Construction

extension Windows.`32`.Kernel.Directory.Create.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        let code = Error_Primitives.Error.captureLastError()
        guard let win32Code = code.win32 else {
            return .platform(Error_Primitives.Error(code: code))
        }

        switch win32Code {
        case Error_Primitives.Error.Code.File.pathNotFound:
            return .notFound
        case Error_Primitives.Error.Code.Access.denied:
            return .permission
        case Error_Primitives.Error.Code.File.exists,
             Error_Primitives.Error.Code.File.alreadyExists:
            return .exists
        case Error_Primitives.Error.Code.Storage.diskFull,
             Error_Primitives.Error.Code.Storage.handleDiskFull:
            return .noSpace
        default:
            return .platform(Error_Primitives.Error(code: code))
        }
    }
}

#endif
