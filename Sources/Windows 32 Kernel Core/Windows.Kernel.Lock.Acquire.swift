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

public import Clock_Primitives

extension Windows.`32`.Kernel.Lock {
    /// Lock acquisition policy. Mirrors `ISO_9945.Kernel.Lock.Acquire`.
    public enum Acquire: Sendable, Equatable {
        /// Try once; fail immediately if contended.
        case `try`

        /// Wait indefinitely.
        case wait

        /// Wait until the continuous-clock deadline.
        case deadline(Clock.Continuous.Instant)
    }
}
