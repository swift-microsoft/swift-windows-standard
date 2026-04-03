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

// MARK: - Windows Memory Map Flags

extension Kernel.Memory.Map.Flags {
    /// Shares modifications with other processes mapping the same file.
    ///
    /// On Windows, this is the default behavior for file mappings.
    public static let shared = Self(rawValue: 1)

    /// Creates a private copy-on-write mapping.
    ///
    /// On Windows, this requires FILE_MAP_COPY when mapping the view.
    public static let `private` = Self(rawValue: 2)

    /// Creates a mapping not backed by any file.
    ///
    /// On Windows, use VirtualAlloc instead of CreateFileMapping.
    public static let anonymous = Self(rawValue: 4)
}

// MARK: - Windows Flags Queries

extension Kernel.Memory.Map.Flags {
    /// Returns true if this is an anonymous (no file) mapping.
    @usableFromInline
    internal var isAnonymous: Bool {
        (rawValue & Self.anonymous.rawValue) != 0
    }

    /// Returns true if this is a copy-on-write private mapping.
    @usableFromInline
    internal var isPrivate: Bool {
        (rawValue & Self.private.rawValue) != 0
    }

    /// Returns true if this is a shared mapping.
    @usableFromInline
    internal var isShared: Bool {
        (rawValue & Self.shared.rawValue) != 0
    }
}

#endif
