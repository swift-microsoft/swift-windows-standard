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

#if os(Windows)

public import Error_Primitives

// MARK: - Windows.`32`.Kernel.Thread.Error structural anchor (post-Tier-5-Windows-Mirror, 2026-05-02)
//
// L2 spec form per [PLAT-ARCH-005]. Hosts the error type thrown by
// `Windows.\`32\`.Kernel.Thread.create(_:)` (declared at
// `Windows.Kernel.Thread.swift:48`).
//
// **Pre-existing condition**: `create(_:)`'s `throws(Windows.\`32\`.Kernel.Thread.Error)`
// clause referenced an undeclared type. Same structural-anchor-completion
// shape as the companion `Windows.\`32\`.Kernel.Thread.Handle` declaration.
// Tier 5-Windows-Event close-report flagged this as a "deferred follow-up
// cycle outside the Tier 5-Windows-Mirror sub-envelope".
//
// **Shape rationale (mechanically derived from existing reference)**:
// - Single case `.create(Error_Primitives.Error)` — matches
//   `Windows.Kernel.Thread.swift:73` throw site
//   (`throw .create(Error_Primitives.Error.captureLastError())`).
// - Other syscall wrappers (`join`, `close`, `current`, `yield`, `currentID`)
//   are non-throwing per their declared signatures, so no additional cases
//   surface from existing references.
// - Conformances mirror `Windows.\`32\`.Kernel.Thread.Affinity.Error` precedent
//   (Swift.Error + Sendable + Equatable + Hashable + CustomStringConvertible).

extension Windows.`32`.Kernel.Thread {
    /// Errors from `Windows.\`32`.Kernel.Thread` syscall wrappers.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// `CreateThread` failed; the wrapped `Error_Primitives.Error`
        /// carries the Win32 last-error code captured at the throw site.
        case create(Error_Primitives.Error)
    }
}

extension Windows.`32`.Kernel.Thread.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .create(let error):
            return "thread create failed: \(error)"
        }
    }
}

#endif
