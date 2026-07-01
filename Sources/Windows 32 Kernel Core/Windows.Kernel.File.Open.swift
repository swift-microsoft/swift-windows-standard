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
    /// File open operations and configuration types.
    ///
    /// Provides the fundamental `open()` syscall for creating or opening files.
    /// Returns a raw ``Kernel/Descriptor`` that must be closed explicitly via
    /// ``Kernel/Close/close(_:)``.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations and types are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945_Kernel`)
    /// - Windows: `swift-windows-standard` (`Windows 32 Kernel File`)
    ///   - `Open.Mode` - GENERIC_READ, GENERIC_WRITE
    ///   - `Open.Options` - CREATE_NEW, TRUNCATE_EXISTING, etc.
    ///   - `Open.open()` - CreateFileW syscall
    ///
    /// ## See Also
    /// - ``Kernel/File/Permissions``
    public struct Open {}
}
