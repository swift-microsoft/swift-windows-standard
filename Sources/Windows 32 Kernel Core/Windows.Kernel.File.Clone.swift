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
    /// Namespace for file cloning (copy-on-write reflink) operations.
    ///
    /// File cloning creates a lightweight copy that shares storage with the original
    /// until either file is modified. This is significantly faster than a byte-by-byte
    /// copy for large files on supported filesystems.
    ///
    /// ## Platform Support
    ///
    /// | Platform | Filesystem | Mechanism |
    /// |----------|------------|-----------|
    /// | macOS | APFS | `clonefile()` |
    /// | Linux | Btrfs, XFS | `ioctl(FICLONE)` |
    /// | Linux | Any | `copy_file_range()` (may CoW) |
    /// | Windows | ReFS | `FSCTL_DUPLICATE_EXTENTS_TO_FILE` |
    public enum Clone {}
}
