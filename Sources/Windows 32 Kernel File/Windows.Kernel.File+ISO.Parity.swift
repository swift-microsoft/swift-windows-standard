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

// MARK: - Move (Path.Borrowed, ISO shape)

extension Windows.`32`.Kernel.File.Move {
    /// Moves (renames) a file or directory.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Move.move(from:to:)` — rename(2)
    /// semantics, which REPLACE an existing destination atomically;
    /// MoveFileExW needs MOVEFILE_REPLACE_EXISTING to match.
    public static func move(
        from oldPath: borrowing Path.Borrowed,
        to newPath: borrowing Path.Borrowed
    ) throws(Windows.`32`.Kernel.File.Move.Error) {
        try unsafe oldPath.withUnsafePointer { oldPtr throws(Windows.`32`.Kernel.File.Move.Error) in
            try unsafe newPath.withUnsafePointer { newPtr throws(Windows.`32`.Kernel.File.Move.Error) in
                try move(from: oldPtr, to: newPtr, replaceExisting: true)
            }
        }
    }
}

// MARK: - Times (access/modification on descriptor, ISO shape)

extension Windows.`32`.Kernel.File.Times {
    /// Sets access and modification times on an open descriptor.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Times.set(access:modification:on:)`
    /// (futimens shape) via `SetFileTime` on the handle.
    public static func set(
        access accessTime: Windows.`32`.Kernel.Time,
        modification modificationTime: Windows.`32`.Kernel.Time,
        on descriptor: borrowing Windows.`32`.Kernel.Descriptor
    ) throws(Windows.`32`.Kernel.File.Times.Error) {
        var access = FILETIME(_from: accessTime)
        var write = FILETIME(_from: modificationTime)
        let handle = UnsafeMutableRawPointer(bitPattern: descriptor._rawValue)
        guard SetFileTime(handle, nil, &access, &write) else {
            throw .platform(Error_Primitives.Error(code: Error_Primitives.Error.captureLastError()))
        }
    }
}

// MARK: - Seek (whence label, ISO shape)

extension Windows.`32`.Kernel.File.Seek {
    /// The reference point for a seek operation (ISO name).
    ///
    /// Mirrors `ISO_9945.Kernel.File.Seek.Whence`; `Origin`'s cases
    /// (`.start`, `.current`, `.end`) coincide with the ISO constants,
    /// so the alias carries call sites written against either name.
    public typealias Whence = Origin

    /// Seeks with the ISO label form.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Seek.seek(_:offset:whence:)`.
    @discardableResult
    public static func seek(
        _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
        offset: Int64,
        whence: Whence
    ) throws(Windows.`32`.Kernel.File.Seek.Error) -> Int64 {
        try seek(descriptor, offset: offset, origin: whence)
    }
}

// MARK: - Hard links (ISO labels)

extension Windows.`32`.Kernel.Link {
    /// Creates a hard link.
    ///
    /// Mirrors `ISO_9945.Kernel.Link.create(at:to:)`.
    public static func create(
        at linkPath: borrowing Path.Borrowed,
        to existingPath: borrowing Path.Borrowed
    ) throws(Windows.`32`.Kernel.Link.Error) {
        try unsafe existingPath.withUnsafePointer { sourcePtr throws(Windows.`32`.Kernel.Link.Error) in
            try unsafe linkPath.withUnsafePointer { linkPtr throws(Windows.`32`.Kernel.Link.Error) in
                try create(source: sourcePtr, linkPath: linkPtr)
            }
        }
    }
}

// MARK: - Attributes (permissions on descriptor, ISO shape)

extension Windows.`32`.Kernel.File.Attributes {
    /// Applies POSIX-style permissions to an open descriptor.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Attributes.set(_:on:)` (fchmod
    /// shape). As with the path form, the only expressible dimension on
    /// Windows is the readonly attribute (owner-write absent → readonly),
    /// applied via `SetFileInformationByHandle(FileBasicInfo)`.
    public static func set(
        _ permissions: Windows.`32`.Kernel.File.Permissions,
        on descriptor: borrowing Windows.`32`.Kernel.Descriptor
    ) throws(Windows.`32`.Kernel.File.Attributes.Error) {
        let handle = UnsafeMutableRawPointer(bitPattern: descriptor._rawValue)
        var info = FILE_BASIC_INFO()
        guard GetFileInformationByHandleEx(
            handle,
            FileBasicInfo,
            &info,
            DWORD(MemoryLayout<FILE_BASIC_INFO>.size)
        ) else {
            throw .platform(Error_Primitives.Error(code: Error_Primitives.Error.captureLastError()))
        }
        let current = info.FileAttributes
        var updated = current
        if (permissions & .ownerWrite) == .none {
            updated |= DWORD(FILE_ATTRIBUTE_READONLY)
        } else {
            updated &= ~DWORD(FILE_ATTRIBUTE_READONLY)
        }
        guard updated != current else { return }
        info.FileAttributes = updated
        // Zero timestamps mean "leave unchanged" for SetFileInformationByHandle.
        info.CreationTime.QuadPart = 0
        info.LastAccessTime.QuadPart = 0
        info.LastWriteTime.QuadPart = 0
        info.ChangeTime.QuadPart = 0
        guard SetFileInformationByHandle(
            handle,
            FileBasicInfo,
            &info,
            DWORD(MemoryLayout<FILE_BASIC_INFO>.size)
        ) else {
            throw .platform(Error_Primitives.Error(code: Error_Primitives.Error.captureLastError()))
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
                // symlink(2) has no file/directory distinction, but
                // CreateSymbolicLinkW requires SYMBOLIC_LINK_FLAG_DIRECTORY
                // for directory targets or the link never resolves. Probe
                // the target; unresolvable (e.g. relative or dangling)
                // targets default to a file link, matching mklink.
                let wTarget = UnsafeRawPointer(targetPtr).assumingMemoryBound(to: WCHAR.self)
                let attributes = GetFileAttributesW(wTarget)
                let isDirectory = attributes != INVALID_FILE_ATTRIBUTES
                    && (attributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0
                try create(target: targetPtr, linkPath: linkPtr, isDirectory: isDirectory)
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
        // GetFinalPathNameByHandleW returns the \\?\-prefixed NT form;
        // strip the prefix so consumers see an ordinary drive path.
        var start = raw
        var count = length
        if length >= 4,
            unsafe raw[0] == 0x5C, unsafe raw[1] == 0x5C,  // backslashes
            unsafe raw[2] == 0x3F, unsafe raw[3] == 0x5C {  // "?" backslash
            start = unsafe raw.advanced(by: 4)
            count = length - 4
        }
        let view = unsafe String_Primitives.String.Borrowed(UnsafePointer(start), count: count)
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
