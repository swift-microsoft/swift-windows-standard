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

internal import Windows_Standard_Core
internal import Kernel_Primitives_Core
internal import Kernel_Descriptor_Primitives
internal import Error_Primitives
internal import Kernel_File_Primitives
internal import Path_Primitives
internal import Kernel_IO_Primitives
internal import Kernel_Thread_Primitives
internal import Kernel_Time_Primitives
internal import Random_Primitives
internal import Kernel_Environment_Primitives
internal import Kernel_Process_Primitives
internal import System_Primitives

#if os(Windows)
public import WinSDK

extension Windows_Standard_Core.Windows.File {
    /// Windows-specific file metadata including creation time.
    ///
    /// This type extends the cross-platform `Kernel.File.Stats` with Windows-specific
    /// fields like `creationTime` that are always available on Windows.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// import Windows_Kernel_Standard
    ///
    /// let stats = try Windows.File.Stats.get(path: "C:\\data.txt")
    /// print("Created: \(stats.creationTime)")  // Non-optional, always available on Windows
    /// print("Size: \(stats.base.size)")
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``Kernel/File/Stats`` for cross-platform file stats
    public struct Stats: Sendable, Equatable {
        /// The cross-platform file stats.
        public let base: Kernel.File.Stats

        /// File creation time.
        ///
        /// This is always available on Windows systems as `ftCreationTime`.
        /// On other platforms, use the platform-specific package or omit this field.
        public let creationTime: Kernel.Time

        /// Creates Windows file stats.
        @inlinable
        public init(base: Kernel.File.Stats, creationTime: Kernel.Time) {
            self.base = base
            self.creationTime = creationTime
        }
    }
}

// MARK: - Convenience accessors

extension Windows_Standard_Core.Windows.File.Stats {
    /// File size in bytes.
    @inlinable
    public var size: Kernel.File.Size { base.size }

    /// File type (regular, directory, symlink, etc.).
    @inlinable
    public var type: Kernel.File.Stats.Kind { base.type }

    /// POSIX file permissions (synthesized from Windows attributes).
    @inlinable
    public var permissions: Kernel.File.Permissions { base.permissions }

    /// Owner user ID (always 0 on Windows).
    @inlinable
    public var uid: Kernel.User.ID { base.uid }

    /// Owner group ID (always 0 on Windows).
    @inlinable
    public var gid: Kernel.Group.ID { base.gid }

    /// Inode number (synthesized from file ID).
    @inlinable
    public var inode: Kernel.Inode { base.inode }

    /// Device ID (from volume serial number).
    @inlinable
    public var device: Kernel.Device { base.device }

    /// Number of hard links.
    @inlinable
    public var linkCount: Kernel.Link.Count { base.linkCount }

    /// Last access time.
    @inlinable
    public var accessTime: Kernel.Time { base.accessTime }

    /// Last modification time.
    @inlinable
    public var modificationTime: Kernel.Time { base.modificationTime }

    /// Status change time (same as modification time on Windows).
    @inlinable
    public var changeTime: Kernel.Time { base.changeTime }
}

// MARK: - Get operations

extension Windows_Standard_Core.Windows.File.Stats {
    /// Error type for Windows file stats operations.
    public typealias Error = Kernel.File.Stats.Error

    /// Gets Windows-specific file metadata for a path (follows symlinks).
    ///
    /// - Parameter path: The path to stat.
    /// - Returns: Windows file metadata including creation time.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    public static func get(path: borrowing Path) throws(Error) -> Self {
        try path.withUnsafeCString { ptr throws(Error) in
            try get(path: UnsafeRawPointer(ptr).assumingMemoryBound(to: WCHAR.self))
        }
    }

    /// Gets Windows-specific file metadata for a path using a wide string.
    ///
    /// - Parameter path: The path as a wide string.
    /// - Returns: Windows file metadata including creation time.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    @_spi(Syscall)
    public static func get(path: UnsafePointer<WCHAR>) throws(Error) -> Self {
        let handle = CreateFileW(
            path,
            DWORD(FILE_READ_ATTRIBUTES),
            DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
            nil,
            DWORD(OPEN_EXISTING),
            DWORD(FILE_FLAG_BACKUP_SEMANTICS),
            nil
        )
        guard handle != INVALID_HANDLE_VALUE else {
            throw Error(_windowsError: GetLastError())
        }
        defer { CloseHandle(handle) }

        var info = BY_HANDLE_FILE_INFORMATION()
        guard GetFileInformationByHandle(handle, &info) else {
            throw Error(_windowsError: GetLastError())
        }
        return Self(_from: info)
    }

    /// Gets Windows-specific file metadata for a path without following symlinks.
    ///
    /// - Parameter path: The path to stat.
    /// - Returns: Windows file metadata including creation time.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    public static func lget(path: borrowing Path) throws(Error) -> Self {
        try path.withUnsafeCString { ptr throws(Error) in
            try lget(path: UnsafeRawPointer(ptr).assumingMemoryBound(to: WCHAR.self))
        }
    }

    /// Gets Windows-specific file metadata for a path using a wide string without following symlinks.
    ///
    /// - Parameter path: The path as a wide string.
    /// - Returns: Windows file metadata including creation time.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    @_spi(Syscall)
    public static func lget(path: UnsafePointer<WCHAR>) throws(Error) -> Self {
        let handle = CreateFileW(
            path,
            DWORD(FILE_READ_ATTRIBUTES),
            DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
            nil,
            DWORD(OPEN_EXISTING),
            DWORD(FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OPEN_REPARSE_POINT),
            nil
        )
        guard handle != INVALID_HANDLE_VALUE else {
            throw Error(_windowsError: GetLastError())
        }
        defer { CloseHandle(handle) }

        var info = BY_HANDLE_FILE_INFORMATION()
        guard GetFileInformationByHandle(handle, &info) else {
            throw Error(_windowsError: GetLastError())
        }
        return Self(_from: info)
    }

    /// Gets Windows-specific file metadata for a HANDLE bit pattern.
    ///
    /// Spec-literal raw `GetFileInformationByHandle`. The typed L2
    /// convenience (`get(descriptor:)` taking `Kernel.Descriptor`) delegates
    /// to this raw SPI internally via `descriptor._rawValue`.
    ///
    /// - Parameter handle: HANDLE bit pattern.
    /// - Returns: Windows file metadata including creation time.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    @_spi(Syscall)
    public static func get(handle: UInt) throws(Error) -> Self {
        var info = BY_HANDLE_FILE_INFORMATION()
        guard GetFileInformationByHandle(UnsafeMutableRawPointer(bitPattern: handle)!, &info) else {
            throw Error(_windowsError: GetLastError())
        }
        return Self(_from: info)
    }

    /// Gets Windows-specific file metadata for an open file descriptor.
    ///
    /// Typed L2 form. Delegates to the raw `get(handle:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter descriptor: The file descriptor to stat.
    /// - Returns: Windows file metadata including creation time.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    public static func get(descriptor: Kernel.Descriptor) throws(Error) -> Self {
        try get(handle: descriptor._rawValue)
    }
}

// MARK: - Internal construction

extension Windows_Standard_Core.Windows.File.Stats {
    /// Creates Windows file stats from a BY_HANDLE_FILE_INFORMATION structure.
    internal init(_from info: BY_HANDLE_FILE_INFORMATION) {
        let size = (Int64(info.nFileSizeHigh) << 32) | Int64(info.nFileSizeLow)

        let type: Kernel.File.Stats.Kind
        if (info.dwFileAttributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0 {
            type = .directory
        } else if (info.dwFileAttributes & DWORD(FILE_ATTRIBUTE_REPARSE_POINT)) != 0 {
            type = .link(.symbolic)
        } else {
            type = .regular
        }

        // Synthesize POSIX-like permissions from Windows attributes
        var permissions: Kernel.File.Permissions = .standard  // Default: rw-r--r-- (0o644)
        if (info.dwFileAttributes & DWORD(FILE_ATTRIBUTE_READONLY)) != 0 {
            permissions = Kernel.File.Permissions(rawValue: 0o444)  // r--r--r--
        }
        if (info.dwFileAttributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0 {
            permissions = Kernel.File.Permissions(rawValue: permissions.rawValue | 0o111)  // Add execute for directories
        }

        let inode = (UInt64(info.nFileIndexHigh) << 32) | UInt64(info.nFileIndexLow)

        let accessTime = Instant(_from: info.ftLastAccessTime)
        let modificationTime = Instant(_from: info.ftLastWriteTime)
        let changeTime = Instant(_from: info.ftLastWriteTime)  // Windows doesn't have ctime
        let creationTime = Instant(_from: info.ftCreationTime)

        let base = Kernel.File.Stats(
            size: Kernel.File.Size(size),
            type: type,
            permissions: permissions,
            uid: .root,
            gid: .root,
            inode: Kernel.Inode(inode),
            device: Kernel.Device(UInt64(info.dwVolumeSerialNumber)),
            linkCount: Kernel.Link.Count(__unchecked: (), Cardinal(UInt(info.nNumberOfLinks))),
            accessTime: accessTime,
            modificationTime: modificationTime,
            changeTime: changeTime
        )

        self.init(base: base, creationTime: creationTime)
    }
}

// MARK: - Error extension for Windows error

extension Kernel.File.Stats.Error {
    /// Creates an error from a Windows error code.
    internal init(_windowsError error: DWORD) {
        let errorCode = Error_Primitives.Error.Code.win32(error)
        if let e = Kernel.Descriptor.Validity.Error(code: errorCode) {
            self = .handle(e)
            return
        }
        if let e = Kernel.IO.Error(code: errorCode) {
            self = .io(e)
            return
        }
        self = .platform(Error_Primitives.Error(code: errorCode))
    }
}

// MARK: - Instant from FILETIME

extension Instant {
    /// Creates an instant from a Windows FILETIME.
    ///
    /// FILETIME is 100-nanosecond intervals since January 1, 1601.
    /// We convert to Unix epoch (January 1, 1970).
    internal init(_from ft: FILETIME) {
        // FILETIME to 100-nanosecond intervals
        let intervals = (Int64(ft.dwHighDateTime) << 32) | Int64(ft.dwLowDateTime)
        // Offset between Windows epoch (1601) and Unix epoch (1970) in 100-ns intervals
        let epochOffset: Int64 = 116_444_736_000_000_000
        let unixIntervals = intervals - epochOffset
        let seconds = unixIntervals / 10_000_000
        let nanoseconds = Int32((unixIntervals % 10_000_000) * 100)
        self.init(
            __unchecked: (),
            secondsSinceUnixEpoch: seconds,
            nanosecondFraction: nanoseconds
        )
    }
}

#endif
