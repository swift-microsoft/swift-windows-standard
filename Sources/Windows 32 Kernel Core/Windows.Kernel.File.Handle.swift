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
    /// An open file handle with resolved Direct I/O disposition.
    /// Mirrors `ISO_9945.Kernel.File.Handle`.
    @frozen
    public struct Handle: ~Copyable, Sendable {
        /// The owned descriptor.
        public let descriptor: Windows.`32`.Kernel.File.Descriptor

        /// The resolved caching mode.
        public let direct: Windows.`32`.Kernel.File.Direct.Mode.Resolved

        /// The Direct I/O requirements discovered at open.
        public let requirements: Windows.`32`.Kernel.File.Direct.Requirements

        public init(
            descriptor: consuming Windows.`32`.Kernel.File.Descriptor,
            direct: Windows.`32`.Kernel.File.Direct.Mode.Resolved,
            requirements: Windows.`32`.Kernel.File.Direct.Requirements
        ) {
            self.descriptor = descriptor
            self.direct = direct
            self.requirements = requirements
        }
    }
}
