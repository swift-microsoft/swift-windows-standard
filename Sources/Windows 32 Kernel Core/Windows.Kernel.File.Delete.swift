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

public import Error_Primitives

extension Windows.`32`.Kernel.File {
    /// File deletion operations.
    ///
    /// Removes directory entries (file names) from the filesystem. On
    /// Windows, deletion may be delayed until all handles are closed.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Delete`. Wraps `DeleteFileW()`.
    ///
    /// - Note: To remove directories, use ``Kernel/Directory/Remove``.
    public enum Delete: Sendable {}
}

// MARK: - Error

extension Windows.`32`.Kernel.File.Delete {
    /// Errors that can occur during file deletion.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The file does not exist.
        case notFound

        /// Permission denied.
        case permission

        /// The path refers to a directory.
        case isDirectory

        /// A component of the path is not a directory.
        case notDirectory

        /// The filesystem is read-only.
        case readOnly

        /// The file is busy (open by another process, etc.).
        case busy

        /// Too many symbolic links encountered.
        case loop

        /// Path name is too long.
        case nameTooLong

        /// A platform-specific error.
        case platform(Error_Primitives.Error)
    }
}

extension Windows.`32`.Kernel.File.Delete.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "file not found"
        case .permission: return "permission denied"
        case .isDirectory: return "is a directory"
        case .notDirectory: return "path component is not a directory"
        case .readOnly: return "read-only filesystem"
        case .busy: return "file busy"
        case .loop: return "too many symbolic links"
        case .nameTooLong: return "path name too long"
        case .platform(let e): return "\(e)"
        }
    }
}
