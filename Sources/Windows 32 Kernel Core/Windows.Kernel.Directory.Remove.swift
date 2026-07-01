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

extension Windows.`32`.Kernel.Directory {
    /// Directory removal operations.
    ///
    /// Removes empty directories from the filesystem.
    ///
    /// Mirrors `ISO_9945.Kernel.Directory.Remove`. Wraps
    /// `RemoveDirectoryW()`.
    ///
    /// - Note: To remove files, use ``Kernel/File/Delete``. To remove
    ///   non-empty directories, first remove all contents recursively.
    public enum Remove: Sendable {}
}

// MARK: - Error

extension Windows.`32`.Kernel.Directory.Remove {
    /// Errors that can occur during directory removal.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The directory does not exist.
        case notFound

        /// Permission denied.
        case permission

        /// The directory is not empty.
        case notEmpty

        /// The path is not a directory.
        case notDirectory

        /// The directory is busy (e.g., current directory of a process).
        case busy

        /// The filesystem is read-only.
        case readOnly

        /// Too many symbolic links encountered.
        case loop

        /// Path name is too long.
        case nameTooLong

        /// A platform-specific error.
        case platform(Error_Primitives.Error)
    }
}

extension Windows.`32`.Kernel.Directory.Remove.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "directory not found"
        case .permission: return "permission denied"
        case .notEmpty: return "directory not empty"
        case .notDirectory: return "not a directory"
        case .busy: return "directory busy"
        case .readOnly: return "read-only filesystem"
        case .loop: return "too many symbolic links"
        case .nameTooLong: return "path name too long"
        case .platform(let e): return "\(e)"
        }
    }
}
