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

// G6.D typealias-via-L3 namespace anchor (per [PLAT-ARCH-005]):
// - Canonical Windows Kernel type is nested under Windows (`Windows.Kernel`).
// - swift-kernel L3 declares `public typealias Kernel = Windows.Kernel`
//   per #if-os to provide the unified cross-platform name.
// - swift-kernel-primitives package no longer exists; the Kernel root
//   namespace lives at L2 spec packages.

public import Windows_32_Core

extension Windows_32_Core.Windows {
    /// Root namespace for kernel-shaped APIs (Windows canonical).
    public enum Kernel: Sendable {}
}
