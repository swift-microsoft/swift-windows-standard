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

public import Time_Primitives

extension Windows.`32`.Kernel {
    /// Wall-clock instant type for the Win32 kernel surface.
    ///
    /// Mirrors `ISO_9945.Kernel.Time` — both alias `Instant` (from
    /// `Time_Primitives`), so the seconds/nanoseconds identity is uniform across
    /// platforms and cross-package consumers (File.Stats, the typed wall-clock
    /// surface) see one `Kernel.Time`.
    public typealias Time = Instant
}
