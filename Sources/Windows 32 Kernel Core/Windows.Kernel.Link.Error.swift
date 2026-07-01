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

extension Windows.`32`.Kernel.Link {
    /// Errors that can occur during hard link operations.
    ///
    /// Mirrors `ISO_9945.Kernel.Link.Error`.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Source file not found.
        case notFound

        /// Permission denied.
        case permission

        /// Link already exists.
        case exists

        /// Cross-device link not allowed.
        case crossDevice

        /// Cannot link directories.
        case isDirectory

        /// A component of the path is not a directory.
        case notDirectory

        /// The filesystem is read-only.
        case readOnly

        /// Too many links to the file.
        case tooManyLinks

        /// Not enough space.
        case noSpace

        /// Too many symbolic links encountered.
        case loop

        /// Path name is too long.
        case nameTooLong

        /// A platform-specific error.
        case platform(Error_Primitives.Error)
    }
}

extension Windows.`32`.Kernel.Link.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "source not found"
        case .permission: return "permission denied"
        case .exists: return "link already exists"
        case .crossDevice: return "cross-device link not allowed"
        case .isDirectory: return "cannot link directories"
        case .notDirectory: return "path component is not a directory"
        case .readOnly: return "read-only filesystem"
        case .tooManyLinks: return "too many links to file"
        case .noSpace: return "no space left on device"
        case .loop: return "too many symbolic links"
        case .nameTooLong: return "path name too long"
        case .platform(let e): return "\(e)"
        }
    }
}
