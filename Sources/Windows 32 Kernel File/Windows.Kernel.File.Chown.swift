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
    /// are synthesized as (0, 0). Each operation is a *conditional* no-op:
    /// it succeeds only when the requested owner equals that synthesized
    /// (0, 0), so cross-platform preserve/apply flows (which round-trip the
    /// synthesized ownership) still succeed; a request for any other owner
    /// throws `.permission(.notPermitted)` rather than silently lying.
    public enum Chown {}
}

// MARK: - Error

extension Windows.`32`.Kernel.File.Chown {
    /// Errors that can occur during chown operations.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Chown.Error`. Thrown as
    /// `.permission(.notPermitted)` when a request asks for an owner other
    /// than the synthesized Windows ownership (0, 0); the full shape exists
    /// so cross-platform error mapping
    /// (`.path`/`.permission`/`.io`/`.platform`) compiles identically on
    /// both legs.
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
    /// Mirrors `ISO_9945.Kernel.File.Chown.chown(path:uid:gid:)`. Windows has
    /// no uid/gid to set: succeeds only when `uid` and `gid` match the
    /// ownership `Stats` synthesizes (0, 0); any other request throws
    /// `.permission(.notPermitted)` rather than silently succeeding.
    public static func chown(
        path: borrowing Path.Borrowed,
        uid: Windows.`32`.Kernel.User.ID,
        gid: Windows.`32`.Kernel.Group.ID
    ) throws(Error) {
        guard uid == .root && gid == .root else {
            throw .permission(.notPermitted)
        }
    }

    /// Changes ownership of the file at `path` without following symlinks.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Chown.lchown(path:uid:gid:)`. Windows has
    /// no uid/gid to set: succeeds only when `uid` and `gid` match the
    /// ownership `Stats` synthesizes (0, 0); any other request throws
    /// `.permission(.notPermitted)` rather than silently succeeding.
    public static func lchown(
        path: borrowing Path.Borrowed,
        uid: Windows.`32`.Kernel.User.ID,
        gid: Windows.`32`.Kernel.Group.ID
    ) throws(Error) {
        guard uid == .root && gid == .root else {
            throw .permission(.notPermitted)
        }
    }

    /// Changes ownership of an open descriptor.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Chown.fchown(_:uid:gid:)`. Windows has
    /// no uid/gid to set: succeeds only when `uid` and `gid` match the
    /// ownership `Stats` synthesizes (0, 0); any other request throws
    /// `.permission(.notPermitted)` rather than silently succeeding.
    public static func fchown(
        _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
        uid: Windows.`32`.Kernel.User.ID,
        gid: Windows.`32`.Kernel.Group.ID
    ) throws(Error) {
        guard uid == .root && gid == .root else {
            throw .permission(.notPermitted)
        }
    }
}

#endif
