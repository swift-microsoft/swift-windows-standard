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

#if os(Windows)

@testable import Windows_32_Kernel

/// Test-module shorthand for the L2 spec namespace.
///
/// Bare `Kernel` is reserved for the L3 unifier ([PLAT-ARCH-008k]); inside
/// this test module it is a private convenience, not API surface.
typealias Kernel = Windows.`32`.Kernel

#endif
