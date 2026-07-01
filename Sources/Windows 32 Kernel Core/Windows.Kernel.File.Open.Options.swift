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

extension Windows.`32`.Kernel.File.Open {
    /// Options that modify file opening behavior.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Open.Options`. The raw value is a
    /// portable intent flag set — Windows has no `O_*` constants, so the
    /// bits are package-defined and converted to Win32 creation disposition
    /// and file flags at the syscall boundary (`Windows 32 Kernel File`).
    /// Multiple options can be combined using set algebra.
    public struct Options: OptionSet, Sendable, Hashable {
        /// The portable open flags.
        public let rawValue: Int32

        /// Creates options from raw flags.
        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}
