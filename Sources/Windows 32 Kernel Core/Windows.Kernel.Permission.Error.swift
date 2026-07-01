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

extension Windows.`32`.Kernel.Permission {
    /// Permission-related errors.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Permission denied - file/directory access control.
        /// - POSIX: `EACCES`
        /// - Windows: `ERROR_ACCESS_DENIED`
        case denied

        /// Operation not permitted - requires elevated privilege.
        /// - POSIX: `EPERM`
        ///
        /// Unlike `.denied`, this indicates the operation itself
        /// requires special privileges (e.g., changing file ownership
        /// to another user).
        case notPermitted

        /// Read-only filesystem.
        /// - POSIX: `EROFS`
        case readOnlyFilesystem
    }
}

// MARK: - CustomStringConvertible

extension Windows.`32`.Kernel.Permission.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .denied:
            return "permission denied"
        case .notPermitted:
            return "operation not permitted"
        case .readOnlyFilesystem:
            return "read-only filesystem"
        }
    }
}
