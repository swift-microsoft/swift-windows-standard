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

// MARK: - Windows CreateSymbolicLinkW syscall

extension Windows.Kernel.Symlink {
    /// Creates a symbolic link.
    ///
    /// On Windows, creating symbolic links typically requires administrator
    /// privileges or Developer Mode to be enabled.
    ///
    /// - Parameters:
    ///   - target: The path the symlink points to.
    ///   - link: The path of the symbolic link to create.
    ///   - isDirectory: If true, creates a directory symlink.
    /// - Throws: `Kernel.Symlink.Error` on failure.
    public static func symlink(
        target: borrowing Kernel.Path,
        link: borrowing Kernel.Path,
        isDirectory: Bool = false
    ) throws(Kernel.Symlink.Error) {
        try symlink(
            target: target.unsafeCString,
            link: link.unsafeCString,
            isDirectory: isDirectory
        )
    }

    /// Creates a symbolic link using unsafe wide strings.
    ///
    /// - Parameters:
    ///   - target: The target path as a null-terminated wide string.
    ///   - link: The link path as a null-terminated wide string.
    ///   - isDirectory: If true, creates a directory symlink.
    /// - Throws: `Kernel.Symlink.Error` on failure.
    public static func symlink(
        target: UnsafePointer<Kernel.Path.Char>,
        link: UnsafePointer<Kernel.Path.Char>,
        isDirectory: Bool = false
    ) throws(Kernel.Symlink.Error) {
        let wTarget = UnsafeRawPointer(target).assumingMemoryBound(to: WCHAR.self)
        let wLink = UnsafeRawPointer(link).assumingMemoryBound(to: WCHAR.self)

        var flags: DWORD = DWORD(SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE)
        if isDirectory {
            flags |= DWORD(SYMBOLIC_LINK_FLAG_DIRECTORY)
        }

        guard CreateSymbolicLinkW(wLink, wTarget, flags) != 0 else {
            throw .current()
        }
    }

    /// Reads the target of a symbolic link.
    ///
    /// - Parameters:
    ///   - path: The path of the symbolic link.
    ///   - buffer: Buffer to receive the target path (UTF-16).
    /// - Returns: The number of characters written (excluding null terminator).
    /// - Throws: `Kernel.Symlink.Error` on failure.
    public static func readlink(
        path: borrowing Kernel.Path,
        into buffer: UnsafeMutableBufferPointer<UInt16>
    ) throws(Kernel.Symlink.Error) -> Int {
        try readlink(unsafePath: path.unsafeCString, into: buffer)
    }

    /// Reads the target of a symbolic link using an unsafe wide string.
    ///
    /// - Parameters:
    ///   - unsafePath: The symlink path as a null-terminated wide string.
    ///   - buffer: Buffer to receive the target path (UTF-16).
    /// - Returns: The number of characters written (excluding null terminator).
    /// - Throws: `Kernel.Symlink.Error` on failure.
    public static func readlink(
        unsafePath: UnsafePointer<Kernel.Path.Char>,
        into buffer: UnsafeMutableBufferPointer<UInt16>
    ) throws(Kernel.Symlink.Error) -> Int {
        let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)

        // Open the symlink with FILE_FLAG_OPEN_REPARSE_POINT
        let handle = CreateFileW(
            wpath,
            0,  // No access needed, just reading reparse data
            DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
            nil,
            DWORD(OPEN_EXISTING),
            DWORD(FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OPEN_REPARSE_POINT),
            nil
        )

        guard handle != INVALID_HANDLE_VALUE else {
            throw .current()
        }
        defer { _ = CloseHandle(handle) }

        // Get the final path name which resolves the symlink
        let wbuffer = UnsafeMutableRawPointer(buffer.baseAddress!).assumingMemoryBound(to: WCHAR.self)
        let result = GetFinalPathNameByHandleW(
            handle,
            wbuffer,
            DWORD(buffer.count),
            DWORD(FILE_NAME_NORMALIZED)
        )

        guard result > 0 else {
            throw .current()
        }

        if result > buffer.count {
            throw .bufferTooSmall
        }

        return Int(result)
    }
}

// MARK: - Error Construction

extension Kernel.Symlink.Error {
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
        case Windows.Kernel.Error.Code.Storage.diskFull,
             Windows.Kernel.Error.Code.Storage.handleDiskFull:
            return .noSpace
        default:
            return .platform(Kernel.Error(code: code))
        }
    }
}

#endif
