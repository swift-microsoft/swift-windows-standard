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

// MARK: - Windows MoveFileExW syscall

extension Windows.Kernel.Rename {
    /// Renames (moves) a file or directory.
    ///
    /// - Parameters:
    ///   - oldPath: The current path of the file or directory.
    ///   - newPath: The new path for the file or directory.
    ///   - replaceExisting: If true, replaces an existing file at newPath.
    /// - Throws: `Kernel.Rename.Error` on failure.
    public static func rename(
        from oldPath: borrowing Kernel.Path,
        to newPath: borrowing Kernel.Path,
        replaceExisting: Bool = false
    ) throws(Kernel.Rename.Error) {
        try rename(
            from: oldPath.unsafeCString,
            to: newPath.unsafeCString,
            replaceExisting: replaceExisting
        )
    }

    /// Renames (moves) a file or directory using unsafe wide strings.
    ///
    /// - Parameters:
    ///   - oldPath: The current path as a null-terminated wide string.
    ///   - newPath: The new path as a null-terminated wide string.
    ///   - replaceExisting: If true, replaces an existing file at newPath.
    /// - Throws: `Kernel.Rename.Error` on failure.
    public static func rename(
        from oldPath: UnsafePointer<Kernel.Path.Char>,
        to newPath: UnsafePointer<Kernel.Path.Char>,
        replaceExisting: Bool = false
    ) throws(Kernel.Rename.Error) {
        let wOldPath = UnsafeRawPointer(oldPath).assumingMemoryBound(to: WCHAR.self)
        let wNewPath = UnsafeRawPointer(newPath).assumingMemoryBound(to: WCHAR.self)

        var flags: DWORD = 0
        if replaceExisting {
            flags |= DWORD(MOVEFILE_REPLACE_EXISTING)
        }

        guard MoveFileExW(wOldPath, wNewPath, flags) else {
            throw .current()
        }
    }
}

// MARK: - Error Construction

extension Kernel.Rename.Error {
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
        case Windows.Kernel.Error.Code.File.exists,
             Windows.Kernel.Error.Code.File.alreadyExists:
            return .exists
        case Windows.Kernel.Error.Code.Access.sharingViolation:
            return .busy
        default:
            return .platform(Kernel.Error(code: code))
        }
    }
}

#endif
