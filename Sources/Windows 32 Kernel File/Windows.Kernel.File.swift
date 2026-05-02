// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Tier 5-Windows-FOS+Affinity-Combined Phase 2 (2026-05-02): introduces the
// `Windows.`32`.Kernel.File` L2 spec namespace anchor that the existing 19+
// `#if os(Windows)`-gated `extension Windows.`32`.Kernel.File.*` references
// in this target (Open, Seek, Move, Stats, Flush, Find, Copy, Delete, Rename,
// Attributes, Times) require to compile on Windows. Per Path X G6.C audit
// (line 3815) the underlying anchor was missing alongside the FOS triple.
//
// L2-canonical-where-spec-layer-exists per [PLAT-ARCH-005]; nominally
// distinct from `ISO_9945.Kernel.File` per [PLAT-ARCH-008k] Spec/Policy
// Namespace Split (Windows is not POSIX per [PLAT-ARCH-007]).

#if os(Windows)

extension Windows.`32`.Kernel {
    /// Root namespace for Win32 file APIs (L2 spec form).
    ///
    /// Hosts file operations (`Open`, `Seek`, `Move`, `Stats`, `Flush`, etc.)
    /// and the typed-value triple (`Offset`, `Size`, `Delta`) that mirror the
    /// `ISO_9945.Kernel.File` shape as a nominally distinct type.
    public enum File: Sendable {}
}

#endif
