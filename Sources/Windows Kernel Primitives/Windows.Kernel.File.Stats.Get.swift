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

// MARK: - Windows File Stats

extension Windows.Kernel.File {
    /// File information retrieved from Windows.
    public struct Stats: Sendable {
        /// File attributes (readonly, hidden, system, directory, archive, etc.).
        public let attributes: DWORD

        /// Creation time as FILETIME.
        public let creationTime: FILETIME

        /// Last access time as FILETIME.
        public let lastAccessTime: FILETIME

        /// Last write time as FILETIME.
        public let lastWriteTime: FILETIME

        /// Volume serial number.
        public let volumeSerialNumber: DWORD

        /// File size in bytes.
        public let size: UInt64

        /// Number of hard links.
        public let numberOfLinks: DWORD

        /// File index (unique identifier on the volume).
        public let fileIndex: UInt64

        init(_ info: BY_HANDLE_FILE_INFORMATION) {
            self.attributes = info.dwFileAttributes
            self.creationTime = info.ftCreationTime
            self.lastAccessTime = info.ftLastAccessTime
            self.lastWriteTime = info.ftLastWriteTime
            self.volumeSerialNumber = info.dwVolumeSerialNumber
            self.size = (UInt64(info.nFileSizeHigh) << 32) | UInt64(info.nFileSizeLow)
            self.numberOfLinks = info.nNumberOfLinks
            self.fileIndex = (UInt64(info.nFileIndexHigh) << 32) | UInt64(info.nFileIndexLow)
        }
    }
}

// MARK: - Attribute Helpers

extension Windows.Kernel.File.Stats {
    /// Whether this is a directory.
    @inlinable
    public var isDirectory: Bool {
        (attributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0
    }

    /// Whether this is a regular file.
    @inlinable
    public var isRegularFile: Bool {
        !isDirectory && !isSymlink
    }

    /// Whether this is a symbolic link (reparse point).
    @inlinable
    public var isSymlink: Bool {
        (attributes & DWORD(FILE_ATTRIBUTE_REPARSE_POINT)) != 0
    }

    /// Whether the file is read-only.
    @inlinable
    public var isReadOnly: Bool {
        (attributes & DWORD(FILE_ATTRIBUTE_READONLY)) != 0
    }

    /// Whether the file is hidden.
    @inlinable
    public var isHidden: Bool {
        (attributes & DWORD(FILE_ATTRIBUTE_HIDDEN)) != 0
    }

    /// Whether the file is a system file.
    @inlinable
    public var isSystem: Bool {
        (attributes & DWORD(FILE_ATTRIBUTE_SYSTEM)) != 0
    }
}

// MARK: - Get Stats

extension Windows.Kernel.File {
    /// Gets file information by handle.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Returns: File stats on success.
    /// - Throws: `Kernel.File.Stats.Error` on failure.
    public static func getStats(
        _ descriptor: Kernel.Descriptor
    ) throws(Kernel.File.Stats.Error) -> Stats {
        var info = BY_HANDLE_FILE_INFORMATION()

        guard GetFileInformationByHandle(descriptor.handle, &info) else {
            throw .get(Windows.Kernel.Error.captureLastError())
        }

        return Stats(info)
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

    /// Gets file size by handle.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Returns: File size in bytes, or nil on failure.
    public static func getSize(
        _ descriptor: Kernel.Descriptor
    ) -> UInt64? {
        var size: LARGE_INTEGER = LARGE_INTEGER()
        guard GetFileSizeEx(descriptor.handle, &size) else {
            return nil
        }
        return UInt64(bitPattern: size.QuadPart)
    }
}

// MARK: - File Type

extension Windows.Kernel.File {
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

    /// Gets the type of a file handle.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Returns: The file type.
    @inlinable
    public static func getType(
        _ descriptor: Kernel.Descriptor
    ) -> FileType {
        let type = GetFileType(descriptor.handle)
        return FileType(rawValue: type) ?? .unknown
    }
}

#endif
