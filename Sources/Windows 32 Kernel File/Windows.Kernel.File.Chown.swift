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
public import Error_Primitives

// MARK: - Windows.`32`.Kernel.File.Chown Namespace

extension Windows.`32`.Kernel.File {
    /// File ownership operations.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Chown` for signature parity —
    /// `swift-iso-9945`'s `Kernel.File.Chown` doc names this type as the
    /// Windows counterpart. Windows has no uid/gid: ownership is
    /// ACL/SID-based, and the uid/gid the Windows `Stats` surface exposes
    /// are synthesized. All operations here are accepted no-ops so
    /// cross-platform preserve/apply flows (which have nothing to carry
    /// over on Windows) succeed rather than fail.
    public enum Chown {}
}

// MARK: - Error

extension Windows.`32`.Kernel.File.Chown {
    /// Errors that can occur during chown operations.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Chown.Error`. Never thrown by the
    /// Windows no-op operations; the shape exists so cross-platform error
    /// mapping (`.path`/`.permission`/`.io`/`.platform`) compiles
    /// identically on both legs.
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

// MARK: - Operations (accepted no-ops)

extension Windows.`32`.Kernel.File.Chown {
    /// Changes ownership of the file at `path` (follows symlinks).
    ///
    /// Mirrors `ISO_9945.Kernel.File.Chown.chown(path:uid:gid:)`.
    /// Accepted no-op on Windows (no uid/gid to set).
    public static func chown(
        path: borrowing Path.Borrowed,
        uid: Windows.`32`.Kernel.User.ID,
        gid: Windows.`32`.Kernel.Group.ID
    ) throws(Error) {
    }

    /// Changes ownership of the file at `path` without following symlinks.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Chown.lchown(path:uid:gid:)`.
    /// Accepted no-op on Windows (no uid/gid to set).
    public static func lchown(
        path: borrowing Path.Borrowed,
        uid: Windows.`32`.Kernel.User.ID,
        gid: Windows.`32`.Kernel.Group.ID
    ) throws(Error) {
    }

    /// Changes ownership of an open descriptor.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Chown.fchown(_:uid:gid:)`.
    /// Accepted no-op on Windows (no uid/gid to set).
    public static func fchown(
        _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
        uid: Windows.`32`.Kernel.User.ID,
        gid: Windows.`32`.Kernel.Group.ID
    ) throws(Error) {
    }
}

#endif
