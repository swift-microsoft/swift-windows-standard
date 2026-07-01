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
    /// File and directory move operations.
    ///
    /// Moves (renames) files and directories atomically within the same
    /// filesystem. Cross-filesystem moves require copy-and-delete.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Move`. Wraps `MoveFileExW()`.
    public enum Move: Sendable {}
}

// MARK: - Error

extension Windows.`32`.Kernel.File.Move {
    /// Errors that can occur during file move operations.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Move.Error`, plus `exists` and `busy` —
    /// unlike POSIX `rename()`, `MoveFileExW` without
    /// `MOVEFILE_REPLACE_EXISTING` fails when the destination exists, and
    /// sharing violations surface when either file is open elsewhere.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The source path does not exist.
        case notFound

        /// Permission denied.
        case permission

        /// The destination already exists (Windows only).
        case exists

        /// The file is in use by another process (Windows only).
        case busy

        /// Source and destination are on different filesystems.
        case crossDevice

        /// The destination is a non-empty directory.
        case notEmpty

        /// A path component is not a directory.
        case notDirectory

        /// Attempting to move a directory to a subdirectory of itself.
        case invalidArgument

        /// The source is a directory but destination is a file.
        case isDirectory

        /// The filesystem is read-only.
        case readOnly

        /// Too many symbolic links encountered.
        case loop

        /// Path name is too long.
        case nameTooLong

        /// Not enough space.
        case noSpace

        /// A platform-specific error.
        case platform(Error_Primitives.Error)
    }
}

extension Windows.`32`.Kernel.File.Move.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "source path not found"
        case .permission: return "permission denied"
        case .exists: return "destination already exists"
        case .busy: return "file in use by another process"
        case .crossDevice: return "cross-device move not supported"
        case .notEmpty: return "destination directory not empty"
        case .notDirectory: return "path component is not a directory"
        case .invalidArgument: return "invalid argument"
        case .isDirectory: return "cannot overwrite directory with file"
        case .readOnly: return "read-only filesystem"
        case .loop: return "too many symbolic links"
        case .nameTooLong: return "path name too long"
        case .noSpace: return "no space left on device"
        case .platform(let e): return "\(e)"
        }
    }
}
