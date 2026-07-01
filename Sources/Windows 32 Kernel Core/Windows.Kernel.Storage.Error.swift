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

extension Windows.`32`.Kernel.Storage {
    /// Space-related errors.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// No space left on device.
        /// - POSIX: `ENOSPC`
        /// - Windows: `ERROR_DISK_FULL`
        case exhausted

        /// User's disk quota exceeded.
        /// - POSIX: `EDQUOT`
        case quota
    }
}

// MARK: - CustomStringConvertible

extension Windows.`32`.Kernel.Storage.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .exhausted:
            return "no space left on device"
        case .quota:
            return "disk quota exceeded"
        }
    }
}

// MARK: - Platform Bindings
//
// Per [PLAT-ARCH-008c], the platform-specific `var code` accessor and
// `init?(code:)` mapping live in L2:
// - POSIX: `swift-iso-9945` (`ISO 9945.Kernel.Storage.Error+code.swift`)
// - Windows: `swift-windows-standard` (`Windows.Kernel.Storage.Error+code.swift`)
