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
internal import WinSDK

// MARK: - Windows CreateFileW syscall

extension Windows.`32`.Kernel.File.Open {
    /// Opens a file at the specified path.
    ///
    /// ## Threading
    /// This call blocks until the open completes. The open syscall may block
    /// on networked filesystems.
    ///
    /// ## Descriptor Ownership
    /// The caller receives ownership of the returned descriptor and must close it
    /// explicitly via ``Kernel/Close/close(_:)``. Failing to close leaks the
    /// kernel resource until process termination.
    ///
    /// ## Errors
    /// - ``Error/notFound``: Path does not exist and `.create` not specified
    /// - ``Error/exists``: Path exists and `.exclusive` was specified
    /// - ``Error/permission``: Insufficient permissions for requested mode
    /// - ``Error/isDirectory``: Cannot open directory without `.backupSemantics`
    /// - ``Error/tooManyOpen``: Process or system handle limit reached
    ///
    /// - Parameters:
    ///   - path: The file path to open.
    ///   - mode: Read/write access mode.
    ///   - options: Creation and behavior options.
    ///   - permissions: File permissions (mostly ignored on Windows, used for readonly attribute).
    /// - Returns: A file descriptor for the opened file.
    /// - Throws: ``Kernel/File/Open/Error`` on failure.
    @inlinable
    public static func open(
        path: borrowing Path,
        mode: Windows.`32`.Kernel.File.Open.Mode,
        options: Windows.`32`.Kernel.File.Open.Options,
        permissions: Windows.`32`.Kernel.File.Permissions = .standard
    ) throws(Windows.`32`.Kernel.File.Open.Error) -> Windows.`32`.Kernel.Descriptor {
        try unsafe path.view.withUnsafePointer { ptr throws(Windows.`32`.Kernel.File.Open.Error) in
            try open(
                unsafePath: ptr,
                mode: mode,
                options: options,
                permissions: permissions
            )
        }
    }

    /// Opens a file at the specified path using an unsafe wide string pointer.
    ///
    /// This is the low-level variant for callers that already have a null-terminated
    /// wide string. Prefer ``open(path:mode:options:permissions:)`` when possible.
    ///
    /// - Parameters:
    ///   - unsafePath: Null-terminated wide string path. Must remain valid for the call duration.
    ///   - mode: Read/write access mode.
    ///   - options: Creation and behavior options.
    ///   - permissions: File permissions (mostly ignored on Windows).
    /// - Returns: A file descriptor for the opened file.
    /// - Throws: ``Kernel/File/Open/Error`` on failure.
    public static func open(
        unsafePath: UnsafePointer<Path.Char>,
        mode: Windows.`32`.Kernel.File.Open.Mode,
        options: Windows.`32`.Kernel.File.Open.Options,
        permissions: Windows.`32`.Kernel.File.Permissions = .standard
    ) throws(Windows.`32`.Kernel.File.Open.Error) -> Windows.`32`.Kernel.Descriptor {
        var desiredAccess = mode.windowsDesiredAccess
        // POSIX O_APPEND semantics: request FILE_APPEND_DATA without
        // FILE_WRITE_DATA so every WriteFile appends atomically at EOF,
        // regardless of the current file pointer.
        if options.contains(.append) && mode.write {
            desiredAccess &= ~DWORD(GENERIC_WRITE)
            desiredAccess |= DWORD(FILE_APPEND_DATA) | DWORD(FILE_WRITE_ATTRIBUTES) | DWORD(SYNCHRONIZE)
        }
        let shareMode: DWORD = DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE)
        let creationDisposition = options.windowsCreationDisposition
        var flagsAndAttributes = options.windowsFlagsAndAttributesFull

        // Apply readonly from permissions if no write requested
        if (permissions & .ownerWrite) == .none && !mode.write {
            flagsAndAttributes |= DWORD(FILE_ATTRIBUTE_READONLY)
        }

        // Cast UInt16 path pointer to WCHAR (they're the same on Windows)
        let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)

        let handle = CreateFileW(
            wpath,
            desiredAccess,
            shareMode,
            nil,
            creationDisposition,
            flagsAndAttributes,
            nil
        )

        guard handle != INVALID_HANDLE_VALUE else {
            throw .current()
        }

        return Windows.`32`.Kernel.Descriptor(_raw: UInt(bitPattern: handle))
    }
}

// MARK: - Error Construction

extension Windows.`32`.Kernel.File.Open.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        Self(code: Error_Primitives.Error.captureLastError())
    }
}

#endif
