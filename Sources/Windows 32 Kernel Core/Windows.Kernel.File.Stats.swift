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

extension Windows.`32`.Kernel.File {
    /// File metadata from Windows file information queries.
    ///
    /// The Windows counterpart of the POSIX stat shape (mirrors
    /// `ISO_9945.Kernel.File.Stats`). Fields without a native Win32
    /// equivalent are synthesized:
    /// - `uid`/`gid`: Always 0 (Windows doesn't have POSIX ownership)
    /// - `inode`: From the file index (unique identifier on the volume)
    /// - `device`: From the volume serial number
    /// - `changeTime`: Uses `ftLastWriteTime` (closest to POSIX ctime)
    ///
    /// For the Windows-native creation time, use `Windows.File.Stats`
    /// (`Windows 32 Kernel File`), which carries this value as `base`
    /// plus `creationTime`.
    ///
    /// ## See Also
    ///
    /// - ``Kernel/File/Stats/Kind``
    /// - ``Kernel/File/Permissions``
    public struct Stats: Sendable, Equatable {
        /// File size in bytes.
        public let size: Windows.`32`.Kernel.File.Size

        /// File type (regular, directory, symlink, etc.).
        public let type: Kind

        /// POSIX-style file permissions, synthesized from file attributes.
        public let permissions: Windows.`32`.Kernel.File.Permissions

        /// Owner user ID. Always 0 on Windows.
        public let uid: Windows.`32`.Kernel.User.ID

        /// Owner group ID. Always 0 on Windows.
        public let gid: Windows.`32`.Kernel.Group.ID

        /// Inode number, synthesized from the file index.
        public let inode: Windows.`32`.Kernel.Inode

        /// Device ID, synthesized from the volume serial number.
        public let device: Windows.`32`.Kernel.Device

        /// Number of hard links.
        public let linkCount: Windows.`32`.Kernel.Link.Count

        /// Last access time.
        public let accessTime: Windows.`32`.Kernel.Time

        /// Last modification time.
        public let modificationTime: Windows.`32`.Kernel.Time

        /// Status change time. Windows does not track metadata changes
        /// separately, so this is `ftLastWriteTime` — the closest match to
        /// POSIX ctime semantics (it updates when the file is modified,
        /// whereas creation time never changes).
        public let changeTime: Windows.`32`.Kernel.Time

        // Note: creationTime is NOT included here to mirror the
        // ISO_9945.Kernel.File.Stats shape. Use Windows.File.Stats for the
        // Windows-native creation time.

        /// Creates a Stats value.
        @inlinable
        public init(
            size: Windows.`32`.Kernel.File.Size,
            type: Kind,
            permissions: Windows.`32`.Kernel.File.Permissions,
            uid: Windows.`32`.Kernel.User.ID,
            gid: Windows.`32`.Kernel.Group.ID,
            inode: Windows.`32`.Kernel.Inode,
            device: Windows.`32`.Kernel.Device,
            linkCount: Windows.`32`.Kernel.Link.Count,
            accessTime: Windows.`32`.Kernel.Time,
            modificationTime: Windows.`32`.Kernel.Time,
            changeTime: Windows.`32`.Kernel.Time
        ) {
            self.size = size
            self.type = type
            self.permissions = permissions
            self.uid = uid
            self.gid = gid
            self.inode = inode
            self.device = device
            self.linkCount = linkCount
            self.accessTime = accessTime
            self.modificationTime = modificationTime
            self.changeTime = changeTime
        }
    }
}
