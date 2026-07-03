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

extension Windows.`32`.Kernel.File.Direct.Requirements {
    /// Why the requirements are unknown. Mirrors
    /// `ISO_9945.Kernel.File.Direct.Requirements.Reason`.
    public enum Reason: Sendable, Equatable, CustomStringConvertible {
        case platformUnsupported
        case sectorSizeUndetermined
        case filesystemUnsupported
        case invalidHandle
    }
}

extension Windows.`32`.Kernel.File.Direct.Requirements.Reason {
    public var description: Swift.String {
        switch self {
        case .platformUnsupported:
            return "Platform does not support strict Direct I/O"
        case .sectorSizeUndetermined:
            return "Could not determine sector size"
        case .filesystemUnsupported:
            return "Filesystem does not support Direct I/O"
        case .invalidHandle:
            return "Invalid file handle"
        }
    }
}
