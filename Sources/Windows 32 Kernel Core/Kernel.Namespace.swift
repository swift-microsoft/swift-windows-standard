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

// Wave 2 Tier 1a Phase 3 namespace anchor (per [PLAT-ARCH-008k]):
// - L2 spec Windows Kernel type is nested under Windows.`32`
//   (Windows.`32`.Kernel) — the spec/policy split per the platform
//   skill's Spec/Policy Namespace Split rule.
// - L3-policy Windows.Kernel is a DISTINCT nominal type declared at
//   swift-foundations/swift-windows (NOT a typealias of this type).
// - swift-kernel L3-unifier resolves cross-platform Kernel.X via
//   public typealias Kernel = Windows.Kernel (the L3-policy form on
//   Windows) per [PLAT-ARCH-008k] — to reach the L2 spec form,
//   consumers write Windows.`32`.Kernel.X explicitly.

public import Windows_32_Core

extension Windows_32_Core.Windows.`32` {
    /// Root namespace for kernel-shaped Win32 APIs (L2 spec form).
    public enum Kernel: Sendable {}
}
