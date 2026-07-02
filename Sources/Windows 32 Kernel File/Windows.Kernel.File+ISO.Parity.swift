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

// ISO 9945 signature parity for the L3 unifier (swift-kernel).
//
// swift-kernel's shared (cross-platform) algorithms — Copy, Clone, Open —
// call the L2 surface with the ISO 9945 signatures (`Path.Borrowed`
// parameters, ISO labels). This file provides those forms on the Windows
// L2 surface, delegating to the existing wide-string implementations.
// The `-standard` convergence rule: both platform L2 packages present the
// same shapes to L3.

#if os(Windows)
public import WinSDK
public import String_Primitives

// MARK: - Stats (get/lget statics, ISO shape)

extension Windows.`32`.Kernel.File.Stats {
    /// Gets file metadata for a path (follows symlinks).
    ///
    /// Mirrors `ISO_9945.Kernel.File.Stats.get(path:)`.
    public static func get(
        path: borrowing Path.Borrowed
    ) throws(Windows.`32`.Kernel.File.Stats.Error) -> Windows.`32`.Kernel.File.Stats {
        try unsafe path.withUnsafePointer { ptr throws(Windows.`32`.Kernel.File.Stats.Error) in
            try _get(unsafePath: ptr, followSymlinks: true)
        }
    }

    /// Gets file metadata for a path without following symlinks.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Stats.lget(path:)`.
    public static func lget(
        path: borrowing Path.Borrowed
    ) throws(Windows.`32`.Kernel.File.Stats.Error) -> Windows.`32`.Kernel.File.Stats {
        try unsafe path.withUnsafePointer { ptr throws(Windows.`32`.Kernel.File.Stats.Error) in
            try _get(unsafePath: ptr, followSymlinks: false)
        }
    }

    /// Gets file metadata for an open descriptor.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Stats.get(descriptor:)`.
    public static func get(
        descriptor: borrowing Windows.`32`.Kernel.Descriptor
    ) throws(Windows.`32`.Kernel.File.Stats.Error) -> Windows.`32`.Kernel.File.Stats {
        try Windows.`32`.Kernel.File.getStats(descriptor._rawValue)
    }

    /// Path-based stat via a metadata-only handle.
    internal static func _get(
        unsafePath: UnsafePointer<Path.Char>,
        followSymlinks: Bool
    ) throws(Windows.`32`.Kernel.File.Stats.Error) -> Windows.`32`.Kernel.File.Stats {
        let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
        var flags = DWORD(FILE_FLAG_BACKUP_SEMANTICS)
        if !followSymlinks {
            flags |= DWORD(FILE_FLAG_OPEN_REPARSE_POINT)
        }
        let handle = CreateFileW(
            wpath,
            DWORD(FILE_READ_ATTRIBUTES),
            DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
            nil,
            DWORD(OPEN_EXISTING),
            flags,
            nil
        )
        guard let handle, handle != INVALID_HANDLE_VALUE else {
            throw .platform(Error_Primitives.Error(code: Error_Primitives.Error.captureLastError()))
        }
        defer { CloseHandle(handle) }

        var info = BY_HANDLE_FILE_INFORMATION()
        guard GetFileInformationByHandle(handle, &info) else {
            throw .platform(Error_Primitives.Error(code: Error_Primitives.Error.captureLastError()))
        }
        return Windows.`32`.Kernel.File.Stats(_from: info)
    }
}

// MARK: - Delete (unlabeled Path.Borrowed, ISO shape)

extension Windows.`32`.Kernel.File.Delete {
    /// Removes a file or symbolic link.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Delete.delete(_:)`.
    public static func delete(
        _ path: borrowing Path.Borrowed
    ) throws(Windows.`32`.Kernel.File.Delete.Error) {
        try unsafe path.withUnsafePointer { ptr throws(Windows.`32`.Kernel.File.Delete.Error) in
            try delete(unsafePath: ptr)
        }
    }
}

// MARK: - Open (Path.Borrowed, ISO shape)

extension Windows.`32`.Kernel.File.Open {
    /// Opens a file at the specified path.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Open.open(path:mode:options:permissions:)`.
    public static func open(
        path: borrowing Path.Borrowed,
        mode: Windows.`32`.Kernel.File.Open.Mode,
        options: Windows.`32`.Kernel.File.Open.Options,
        permissions: Windows.`32`.Kernel.File.Permissions = .standard
    ) throws(Windows.`32`.Kernel.File.Open.Error) -> Windows.`32`.Kernel.Descriptor {
        try unsafe path.withUnsafePointer { ptr throws(Windows.`32`.Kernel.File.Open.Error) in
            try open(unsafePath: ptr, mode: mode, options: options, permissions: permissions)
        }
    }
}

// MARK: - Times (access/modification at path, ISO shape)

extension Windows.`32`.Kernel.File.Times {
    /// Sets access and modification times for a path.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Times.set(access:modification:at:)`.
    public static func set(
        access accessTime: Windows.`32`.Kernel.Time,
        modification modificationTime: Windows.`32`.Kernel.Time,
        at path: borrowing Path.Borrowed
    ) throws(Windows.`32`.Kernel.File.Times.Error) {
        try unsafe path.withUnsafePointer { ptr throws(Windows.`32`.Kernel.File.Times.Error) in
            let wpath = UnsafeRawPointer(ptr).assumingMemoryBound(to: WCHAR.self)
            let handle = CreateFileW(
                wpath,
                DWORD(FILE_WRITE_ATTRIBUTES),
                DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                nil,
                DWORD(OPEN_EXISTING),
                DWORD(FILE_FLAG_BACKUP_SEMANTICS),
                nil
            )
            guard let handle, handle != INVALID_HANDLE_VALUE else {
                throw .platform(Error_Primitives.Error(code: Error_Primitives.Error.captureLastError()))
            }
            defer { CloseHandle(handle) }

            var access = FILETIME(_from: accessTime)
            var write = FILETIME(_from: modificationTime)
            guard SetFileTime(handle, nil, &access, &write) else {
                throw .platform(Error_Primitives.Error(code: Error_Primitives.Error.captureLastError()))
            }
        }
    }
}

// MARK: - Attributes (permissions at path, ISO shape)

extension Windows.`32`.Kernel.File.Attributes {
    /// Applies POSIX-style permissions to a path.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Attributes.set(_:at:)`. Windows has no
    /// mode bits; the only expressible dimension is the readonly attribute
    /// (owner-write absent → readonly), matching the synthesis direction
    /// used by `Stats`.
    public static func set(
        _ permissions: Windows.`32`.Kernel.File.Permissions,
        at path: borrowing Path.Borrowed
    ) throws(Windows.`32`.Kernel.File.Attributes.Error) {
        try unsafe path.withUnsafePointer { ptr throws(Windows.`32`.Kernel.File.Attributes.Error) in
            let wpath = UnsafeRawPointer(ptr).assumingMemoryBound(to: WCHAR.self)
            let current = GetFileAttributesW(wpath)
            guard current != INVALID_FILE_ATTRIBUTES else {
                throw .platform(Error_Primitives.Error(code: Error_Primitives.Error.captureLastError()))
            }
            var updated = current
            if (permissions & .ownerWrite) == .none {
                updated |= DWORD(FILE_ATTRIBUTE_READONLY)
            } else {
                updated &= ~DWORD(FILE_ATTRIBUTE_READONLY)
            }
            guard updated == current || SetFileAttributesW(wpath, updated) else {
                throw .platform(Error_Primitives.Error(code: Error_Primitives.Error.captureLastError()))
            }
        }
    }
}

// MARK: - Symbolic links (ISO labels)

extension Windows.`32`.Kernel.Link.Symbolic {
    /// Creates a symbolic link.
    ///
    /// Mirrors `ISO_9945.Kernel.Link.Symbolic.create(target:at:)`.
    public static func create(
        target: borrowing Path.Borrowed,
        at linkPath: borrowing Path.Borrowed
    ) throws(Windows.`32`.Kernel.Link.Symbolic.Error) {
        try unsafe target.withUnsafePointer { targetPtr throws(Windows.`32`.Kernel.Link.Symbolic.Error) in
            try unsafe linkPath.withUnsafePointer { linkPtr throws(Windows.`32`.Kernel.Link.Symbolic.Error) in
                try create(target: targetPtr, linkPath: linkPtr)
            }
        }
    }

    /// Reads the target of a symbolic link.
    ///
    /// Mirrors `ISO_9945.Kernel.Link.Symbolic.readTarget(at:)`.
    public static func readTarget(
        at path: borrowing Path.Borrowed
    ) throws(Windows.`32`.Kernel.Link.Symbolic.Error) -> String_Primitives.String {
        // MAX_PATH-scale buffer; reparse targets beyond this surface as
        // bufferTooSmall from the underlying read. Raw allocation rather
        // than Array.withUnsafeMutableBufferPointer: the rethrows closure
        // erases the typed throw to any Error.
        let capacity = 32768
        let raw = UnsafeMutablePointer<UInt16>.allocate(capacity: capacity)
        defer { unsafe raw.deallocate() }
        unsafe raw.initialize(repeating: 0, count: capacity)
        let buf = unsafe UnsafeMutableBufferPointer(start: raw, count: capacity)
        let length = try unsafe path.withUnsafePointer { ptr throws(Windows.`32`.Kernel.Link.Symbolic.Error) in
            try unsafe readTarget(unsafePath: ptr, into: buf)
        }
        let view = unsafe String_Primitives.String.Borrowed(UnsafePointer(raw), count: length)
        return unsafe String_Primitives.String(copying: view)
    }
}

// MARK: - FILETIME from Instant

extension FILETIME {
    /// Converts a Unix-epoch instant to a Windows FILETIME
    /// (100-nanosecond intervals since 1601-01-01).
    internal init(_from instant: Windows.`32`.Kernel.Time) {
        let epochOffset: Int64 = 116_444_736_000_000_000
        let intervals = instant.secondsSinceUnixEpoch * 10_000_000
            + Int64(instant.nanosecondFraction) / 100
            + epochOffset
        self.init(
            dwLowDateTime: DWORD(truncatingIfNeeded: intervals),
            dwHighDateTime: DWORD(truncatingIfNeeded: intervals >> 32)
        )
    }
}

#endif
