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

public import Tagged_Primitives

extension Windows.`32`.Kernel {
    /// Group-related types.
    ///
    /// Mirrors `ISO_9945.Kernel.Group`. Windows does not have POSIX group
    /// IDs; stats synthesis reports `.root` (0).
    public enum Group: Sendable {}
}

extension Windows.`32`.Kernel.Group {
    /// Group identifier (POSIX `gid_t` width: `UInt32`).
    public typealias ID = Tagged<Windows.`32`.Kernel.Group, UInt32>
}

extension Tagged where Tag == Windows.`32`.Kernel.Group, Underlying == UInt32 {
    /// The root group (gid 0).
    public static var root: Self { .zero }
}
