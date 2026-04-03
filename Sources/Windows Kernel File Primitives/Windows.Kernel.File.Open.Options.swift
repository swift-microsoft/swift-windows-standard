// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
@_spi(Syscall) public import Kernel_Primitives
public import WinSDK

// MARK: - Windows file open options conversion

extension Kernel.File.Open.Options {
    /// Converts the options to Windows creation disposition.
    ///
    /// Maps the portable `Options` flags to Win32 creation disposition values:
    /// - `CREATE_NEW` - Creates a new file, fails if exists
    /// - `CREATE_ALWAYS` - Creates a new file, overwrites if exists
    /// - `OPEN_EXISTING` - Opens existing file, fails if not exists
    /// - `OPEN_ALWAYS` - Opens existing or creates new
    /// - `TRUNCATE_EXISTING` - Opens and truncates existing file
    @usableFromInline
    internal var windowsCreationDisposition: DWORD {
        let hasCreate = contains(.create)
        let hasExclusive = contains(.exclusive)
        let hasTruncate = contains(.truncate)

        if hasCreate && hasExclusive {
            // Create new, fail if exists
            return DWORD(CREATE_NEW)
        } else if hasCreate && hasTruncate {
            // Create or overwrite
            return DWORD(CREATE_ALWAYS)
        } else if hasCreate {
            // Create if not exists, open if exists
            return DWORD(OPEN_ALWAYS)
        } else if hasTruncate {
            // Open existing and truncate
            return DWORD(TRUNCATE_EXISTING)
        } else {
            // Open existing only
            return DWORD(OPEN_EXISTING)
        }
    }

    /// Converts the options to Windows flags and attributes.
    ///
    /// Maps portable flags to Win32 file flags:
    /// - `FILE_FLAG_NO_BUFFERING` for direct I/O
    /// - `FILE_FLAG_OVERLAPPED` for async I/O (when specified)
    /// - `FILE_FLAG_OPEN_REPARSE_POINT` for noFollow
    @usableFromInline
    internal var windowsFlagsAndAttributes: DWORD {
        var flags: DWORD = DWORD(FILE_ATTRIBUTE_NORMAL)

        if contains(.direct) {
            flags |= DWORD(FILE_FLAG_NO_BUFFERING)
            flags |= DWORD(FILE_FLAG_WRITE_THROUGH)
        }

        if contains(.noFollow) {
            flags |= DWORD(FILE_FLAG_OPEN_REPARSE_POINT)
        }

        return flags
    }

    /// Returns Windows flags with overlapped I/O enabled.
    ///
    /// Used when opening files for async I/O with I/O Completion Ports.
    @usableFromInline
    internal var windowsFlagsAndAttributesOverlapped: DWORD {
        windowsFlagsAndAttributes | DWORD(FILE_FLAG_OVERLAPPED)
    }
}

// MARK: - Windows-specific Options

extension Kernel.File.Open.Options {
    /// Opens the file for overlapped (async) I/O.
    ///
    /// Required when using I/O Completion Ports. Windows-specific.
    public static let overlapped = Self(rawValue: 1 << 16)

    /// Opens file for backup semantics (allows opening directories).
    ///
    /// Windows-specific. Required when opening directories.
    public static let backupSemantics = Self(rawValue: 1 << 17)

    /// Requests delete access (for delete-on-close).
    ///
    /// Windows-specific.
    public static let deleteOnClose = Self(rawValue: 1 << 18)
}

// MARK: - Extended Windows flags conversion

extension Kernel.File.Open.Options {
    /// Full Windows flags conversion including Windows-specific options.
    @usableFromInline
    internal var windowsFlagsAndAttributesFull: DWORD {
        var flags = windowsFlagsAndAttributes

        if contains(.overlapped) {
            flags |= DWORD(FILE_FLAG_OVERLAPPED)
        }

        if contains(.backupSemantics) {
            flags |= DWORD(FILE_FLAG_BACKUP_SEMANTICS)
        }

        if contains(.deleteOnClose) {
            flags |= DWORD(FILE_FLAG_DELETE_ON_CLOSE)
        }

        return flags
    }
}

#endif
