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

public import Memory_Primitives

extension Windows.`32`.Kernel.File.Direct.Requirements {
    /// The alignment triple for Direct I/O. Mirrors
    /// `ISO_9945.Kernel.File.Direct.Requirements.Alignment`.
    public struct Alignment: Sendable, Equatable {
        /// Required buffer-address alignment.
        public let bufferAlignment: Memory.Alignment

        /// Required file-offset alignment.
        public let offsetAlignment: Memory.Alignment

        /// Required transfer-length multiple.
        public let lengthMultiple: Memory.Alignment

        public init(
            bufferAlignment: Memory.Alignment,
            offsetAlignment: Memory.Alignment,
            lengthMultiple: Memory.Alignment
        ) {
            self.bufferAlignment = bufferAlignment
            self.offsetAlignment = offsetAlignment
            self.lengthMultiple = lengthMultiple
        }

        /// Uniform alignment for all three requirements.
        public init(uniform alignment: Memory.Alignment) {
            self.bufferAlignment = alignment
            self.offsetAlignment = alignment
            self.lengthMultiple = alignment
        }
    }
}
