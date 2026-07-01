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

extension Windows.`32`.Kernel.File.System.Stats {
    /// Error type for filesystem statistics operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        case path(Path.Resolution.Error)
        case handle(Windows.`32`.Kernel.Descriptor.Validity.Error)
        case platform(Error_Primitives.Error)
    }
}

extension Windows.`32`.Kernel.File.System.Stats.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .path(let e): return "path: \(e)"
        case .handle(let e): return "handle: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}
