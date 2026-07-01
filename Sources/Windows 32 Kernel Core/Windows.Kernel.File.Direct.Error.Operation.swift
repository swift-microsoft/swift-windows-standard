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

extension Windows.`32`.Kernel.File.Direct.Error {
    /// Direct I/O operation types for syscall error context.
    public enum Operation: Sendable, Equatable {
        case open
        case cache(Cache)
        case sector(Sector)
        case read
        case write

        /// Cache operation types.
        public enum Cache: Swift.String, Sendable, Equatable {
            case set
            case clear
        }

        /// Sector operation types.
        public enum Sector: Swift.String, Sendable, Equatable {
            case getSize
        }
    }
}
