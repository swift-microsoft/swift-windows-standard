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
    /// Root namespace for Win32 I/O operations (L2 spec form).
    ///
    /// Hosts the read/write/blocking operation namespaces and their error types.
    /// Anchored in Kernel Core (unguarded) so both the Core error layer and the
    /// downstream `Windows 32 Kernel IO` operation target resolve it, mirroring
    /// `ISO_9945.Kernel.IO` as a nominally distinct type per [PLAT-ARCH-008k].
    public enum IO: Sendable {}
}
