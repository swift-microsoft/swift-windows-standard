// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-standard open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
public import WinSDK

// MARK: - Stats Synthesis

extension Windows.`32`.Kernel.File.Stats {
    /// Creates kernel file stats from a BY_HANDLE_FILE_INFORMATION structure.
    ///
    /// Synthesizes the POSIX-mirror fields from Win32 file information:
    /// type from attributes, permissions from the readonly bit, inode from
    /// the file index, device from the volume serial number, and
    /// `changeTime` from `ftLastWriteTime` (Windows has no ctime).
    internal init(_from info: BY_HANDLE_FILE_INFORMATION) {
        let size = (Int64(info.nFileSizeHigh) << 32) | Int64(info.nFileSizeLow)

        let type: Windows.`32`.Kernel.File.Stats.Kind
        if (info.dwFileAttributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0 {
            type = .directory
        } else if (info.dwFileAttributes & DWORD(FILE_ATTRIBUTE_REPARSE_POINT)) != 0 {
            type = .link(.symbolic)
        } else {
            type = .regular
        }

        // Synthesize POSIX-like permissions from Windows attributes
        var permissions: Windows.`32`.Kernel.File.Permissions = .standard  // Default: rw-r--r-- (0o644)
        if (info.dwFileAttributes & DWORD(FILE_ATTRIBUTE_READONLY)) != 0 {
            permissions = Windows.`32`.Kernel.File.Permissions(rawValue: 0o444)  // r--r--r--
        }
        if (info.dwFileAttributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0 {
            permissions = permissions | Windows.`32`.Kernel.File.Permissions(rawValue: 0o111)  // Add execute for directories
        }

        let inode = (UInt64(info.nFileIndexHigh) << 32) | UInt64(info.nFileIndexLow)

        self.init(
            size: Windows.`32`.Kernel.File.Size(size),
            type: type,
            permissions: permissions,
            uid: .root,
            gid: .root,
            inode: Windows.`32`.Kernel.Inode(inode),
            device: Windows.`32`.Kernel.Device(UInt64(info.dwVolumeSerialNumber)),
            linkCount: Windows.`32`.Kernel.Link.Count(__unchecked: (), Cardinal(UInt(info.nNumberOfLinks))),
            accessTime: Instant(_from: info.ftLastAccessTime),
            modificationTime: Instant(_from: info.ftLastWriteTime),
            changeTime: Instant(_from: info.ftLastWriteTime)  // Windows doesn't have ctime
        )
    }
}

// MARK: - Get Stats (raw @_spi(Syscall))

extension Windows.`32`.Kernel.File {
    /// Gets file information for a HANDLE bit pattern.
    ///
    /// Spec-literal raw `GetFileInformationByHandle`. The typed L2
    /// convenience (`getStats(_:)` taking `Windows.`32`.Kernel.Descriptor`) delegates to
    /// this raw SPI internally via `descriptor._rawValue`.
    ///
    /// - Parameter handle: HANDLE bit pattern.
    /// - Returns: File stats on success.
    /// - Throws: `Windows.`32`.Kernel.File.Stats.Error` on failure.
    package static func getStats(
        _ handle: UInt
    ) throws(Windows.`32`.Kernel.File.Stats.Error) -> Stats {
        var info = BY_HANDLE_FILE_INFORMATION()

        guard GetFileInformationByHandle(UnsafeMutableRawPointer(bitPattern: handle)!, &info) else {
            throw .platform(Error_Primitives.Error(code: Error_Primitives.Error.captureLastError()))
        }

        return Stats(_from: info)
    }

    /// Gets file attributes by path.
    ///
    /// - Parameter path: The file path.
    /// - Returns: File attributes, or `INVALID_FILE_ATTRIBUTES` on failure.
    @inlinable
    public static func getAttributes(
        path: UnsafePointer<WCHAR>
    ) -> DWORD {
        GetFileAttributesW(path)
    }

    /// Gets file size for a HANDLE bit pattern.
    ///
    /// Spec-literal raw `GetFileSizeEx`. The typed L2 convenience
    /// (`getSize(_:)` taking `Windows.`32`.Kernel.Descriptor`) delegates to this raw SPI
    /// internally via `descriptor._rawValue`.
    ///
    /// - Parameter handle: HANDLE bit pattern.
    /// - Returns: File size in bytes, or nil on failure.
    package static func getSize(
        _ handle: UInt
    ) -> UInt64? {
        var size: LARGE_INTEGER = LARGE_INTEGER()
        guard GetFileSizeEx(UnsafeMutableRawPointer(bitPattern: handle)!, &size) else {
            return nil
        }
        return UInt64(bitPattern: size.QuadPart)
    }
}

// MARK: - Get Stats (typed convenience)

extension Windows.`32`.Kernel.File {
    /// Gets file information by handle.
    ///
    /// Typed L2 form. Delegates to the raw `getStats(_:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Returns: File stats on success.
    /// - Throws: `Windows.`32`.Kernel.File.Stats.Error` on failure.
    public static func getStats(
        _ descriptor: borrowing Windows.`32`.Kernel.Descriptor
    ) throws(Windows.`32`.Kernel.File.Stats.Error) -> Stats {
        try getStats(descriptor._rawValue)
    }

    /// Gets file size by handle.
    ///
    /// Typed L2 form. Delegates to the raw `getSize(_:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Returns: File size in bytes, or nil on failure.
    public static func getSize(
        _ descriptor: borrowing Windows.`32`.Kernel.Descriptor
    ) -> UInt64? {
        getSize(descriptor._rawValue)
    }
}

// MARK: - Path-Based Stats

extension Windows.`32`.Kernel.File {
    /// Checks if a file or directory exists at the given path.
    ///
    /// - Parameter path: The path to check.
    /// - Returns: True if the path exists, false otherwise.
    @inlinable
    public static func exists(path: borrowing Path) -> Bool {
        unsafe path.view.withUnsafePointer { ptr in
            let wpath = UnsafeRawPointer(ptr).assumingMemoryBound(to: WCHAR.self)
            return GetFileAttributesW(wpath) != INVALID_FILE_ATTRIBUTES
        }
    }

    /// Checks if a file or directory exists at the given path.
    ///
    /// - Parameter path: The path as a null-terminated wide string.
    /// - Returns: True if the path exists, false otherwise.
    @inlinable
    package static func exists(path: UnsafePointer<WCHAR>) -> Bool {
        GetFileAttributesW(path) != INVALID_FILE_ATTRIBUTES
    }

    /// Gets file attributes by path, returning nil if the file doesn't exist.
    ///
    /// - Parameter path: The path to check.
    /// - Returns: The file attributes, or nil if the file doesn't exist.
    @inlinable
    public static func getAttributes(path: borrowing Path) -> Attributes? {
        unsafe path.view.withUnsafePointer { ptr in
            let wpath = UnsafeRawPointer(ptr).assumingMemoryBound(to: WCHAR.self)
            let result = GetFileAttributesW(wpath)
            guard result != INVALID_FILE_ATTRIBUTES else {
                return nil
            }
            return Attributes(rawValue: result)
        }
    }

    /// Checks if the path is a directory.
    ///
    /// - Parameter path: The path to check.
    /// - Returns: True if the path is a directory, false otherwise (including if it doesn't exist).
    @inlinable
    public static func isDirectory(path: borrowing Path) -> Bool {
        guard let attrs = getAttributes(path: path) else {
            return false
        }
        return attrs.contains(.directory)
    }

    /// Checks if the path is a regular file (not a directory or reparse point).
    ///
    /// - Parameter path: The path to check.
    /// - Returns: True if the path is a regular file, false otherwise.
    @inlinable
    public static func isRegularFile(path: borrowing Path) -> Bool {
        guard let attrs = getAttributes(path: path) else {
            return false
        }
        return !attrs.contains(.directory) && !attrs.contains(.reparsePoint)
    }
}

// MARK: - File Type

extension Windows.`32`.Kernel.File {
    /// Windows file type.
    public enum FileType: DWORD, Sendable {
        /// Unknown type.
        case unknown = 0x0000 // FILE_TYPE_UNKNOWN

        /// Disk file.
        case disk = 0x0001 // FILE_TYPE_DISK

        /// Character device (console, serial port).
        case char = 0x0002 // FILE_TYPE_CHAR

        /// Named or anonymous pipe.
        case pipe = 0x0003 // FILE_TYPE_PIPE
    }

    /// Gets the type for a HANDLE bit pattern (raw `GetFileType`).
    ///
    /// Spec-literal raw `GetFileType`. The typed L2 convenience
    /// (`getType(_:)` taking `Windows.`32`.Kernel.Descriptor`) delegates to this raw SPI
    /// internally via `descriptor._rawValue`.
    ///
    /// - Parameter handle: HANDLE bit pattern.
    /// - Returns: The file type.
    @inlinable
    package static func getType(
        _ handle: UInt
    ) -> FileType {
        let type = GetFileType(UnsafeMutableRawPointer(bitPattern: handle)!)
        return FileType(rawValue: type) ?? .unknown
    }

    /// Gets the type of a file handle.
    ///
    /// Typed L2 form. Delegates to the raw `getType(_:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Returns: The file type.
    public static func getType(
        _ descriptor: borrowing Windows.`32`.Kernel.Descriptor
    ) -> FileType {
        getType(descriptor._rawValue)
    }
}

#endif
