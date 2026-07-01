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

extension Windows.`32`.Kernel.Lock {
    /// Lock operation errors.
    ///
    /// Type shape mirrors `ISO_9945.Kernel.Lock.Error` exactly (the cross-platform
    /// contract); the Win32 code mapping lives in `Windows.Kernel.Lock.Error+code`.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Lock contention — another process holds a conflicting lock
        /// (`ERROR_LOCK_VIOLATION`). Only surfaced for non-blocking acquisition.
        case contention

        /// Deadlock detected by the kernel.
        case deadlock

        /// No locks available — the system lock table is exhausted.
        case unavailable
    }
}

extension Windows.`32`.Kernel.Lock.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .contention: return "lock contention"
        case .deadlock: return "deadlock detected"
        case .unavailable: return "no locks available"
        }
    }
}

extension Windows.`32`.Kernel.Lock.Error {
    /// Lock acquisition timed out (semantically reuses `.contention`).
    public static let timedOut = Self.contention

    /// Lock would block, for non-blocking acquisition (reuses `.contention`).
    public static let wouldBlock = Self.contention
}
