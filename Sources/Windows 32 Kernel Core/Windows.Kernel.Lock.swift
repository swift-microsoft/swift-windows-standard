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

extension Windows.`32`.Kernel {
    /// Root namespace for Win32 file/byte-range locking operations (L2 spec form).
    ///
    /// Mirrors `ISO_9945.Kernel.Lock` as a nominally distinct type per
    /// [PLAT-ARCH-008k].
    public enum Lock: Sendable {}
}
