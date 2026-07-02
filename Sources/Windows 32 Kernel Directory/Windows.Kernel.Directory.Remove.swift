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

// MARK: - Windows RemoveDirectoryW syscall

extension Windows.`32`.Kernel.Directory.Remove {
    /// Removes an empty directory.
    ///
    /// - Parameter path: The path of the directory to remove.
    /// - Throws: `Windows.`32`.Kernel.Directory.Remove.Error` on failure.
    public static func remove(
        path: borrowing Path
    ) throws(Windows.`32`.Kernel.Directory.Remove.Error) {
        try unsafe path.view.withUnsafePointer { ptr throws(Windows.`32`.Kernel.Directory.Remove.Error) in
            try remove(unsafePath: ptr)
        }
    }

    /// Removes an empty directory using an unsafe wide string.
    ///
    /// - Parameter unsafePath: The path as a null-terminated wide string.
    /// - Throws: `Windows.`32`.Kernel.Directory.Remove.Error` on failure.
    public static func remove(
        unsafePath: UnsafePointer<Path.Char>
    ) throws(Windows.`32`.Kernel.Directory.Remove.Error) {
        let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
        guard RemoveDirectoryW(wpath) else {
            throw .current()
        }
    }
}

// MARK: - Error Construction

extension Windows.`32`.Kernel.Directory.Remove.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        let code = Error_Primitives.Error.captureLastError()
        guard let win32Code = code.win32 else {
            return .platform(Error_Primitives.Error(code: code))
        }
        return current(from: win32Code)
    }

    /// Maps a Win32 error code to the semantic error (testing seam).
    package static func current(from win32Code: UInt32) -> Self {
        switch win32Code {
        case Error_Primitives.Error.Code.File.notFound,
             Error_Primitives.Error.Code.File.pathNotFound:
            return .notFound
        case Error_Primitives.Error.Code.Access.denied:
            return .permission
        case Error_Primitives.Error.Code.Directory.notEmpty:
            return .notEmpty
        case Error_Primitives.Error.Code.Access.sharingViolation:
            return .busy
        default:
            return .platform(Error_Primitives.Error(code: .win32(win32Code)))
        }
    }
}

#endif
