// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

/// Windows platform namespace.
public enum Windows {}

extension Windows {
    /// Win32 spec sub-namespace per [PLAT-ARCH-008k].
    ///
    /// Per the platform skill's Spec/Policy Namespace Split, the L2 spec
    /// encoding for the Microsoft Win32 API lives under Windows.`32`,
    /// distinct from the L3-policy Windows.Kernel declared in
    /// swift-foundations/swift-windows. The two are genuinely distinct
    /// nominal types — same Windows parent root, different sub-types —
    /// so same-signature methods (e.g., close(_:)) coexist cleanly.
    ///
    /// Backtick-escaped digit-starting identifier mechanically verified
    /// against Apple Swift 6.3.1.
    public enum `32`: Sendable {}
}
