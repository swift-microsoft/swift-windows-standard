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

// G6.D parallel-roots: `Kernel` namespace declared at windows-standard L2.
// Per Path X terminal step, swift-kernel-primitives package no longer
// exists; the Kernel root namespace lives at L2 spec packages directly
// (parallel declarations at iso-9945 + windows-standard). Cross-platform
// consumers reach exactly one Kernel via swift-kernel L3's conditional
// re-export of the platform L2.

/// Root namespace for kernel-shaped APIs.
public enum Kernel: Sendable {}
