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
    /// File timestamp operations.
    ///
    /// Provides file timestamp modification.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Times`. Wraps `SetFileTime()`.
    public enum Times {}
}

// MARK: - Error

extension Windows.`32`.Kernel.File.Times {
    /// Errors that can occur during file timestamp operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The path does not exist.
        case path(Path)

        /// Permission errors.
        case permission(Permission)

        /// I/O errors.
        case io(IO)

        /// Platform-specific error.
        case platform(Error_Primitives.Error)

        // Path-related errors
        public enum Path: Swift.Error, Sendable, Equatable {
            case notFound
            case tooLong
            case loop
        }

        // Permission-related errors
        public enum Permission: Swift.Error, Sendable, Equatable {
            case denied
            case notPermitted
            case readOnlyFilesystem
        }

        // I/O errors
        public enum IO: Swift.Error, Sendable, Equatable {
            case hardware
        }
    }
}

extension Windows.`32`.Kernel.File.Times.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .path(let pathError):
            return "file times path error: \(pathError)"
        case .permission(let permError):
            return "file times permission error: \(permError)"
        case .io(let ioError):
            return "file times I/O error: \(ioError)"
        case .platform(let e):
            return "file times error: \(e)"
        }
    }
}
