// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)

public import WinSDK

extension Windows.`32`.Kernel.Thread {
    /// Opaque OS thread identifier on Windows.
    ///
    /// The raw value is the thread ID (`DWORD`) as returned by
    /// `GetCurrentThreadId()`. Unique within a process; Windows may reuse IDs
    /// after a thread terminates, but not while it's live.
    ///
    /// Not portable across processes or platforms. Within a single process,
    /// two `ID` values compare equal iff they refer to the same live OS thread.
    public struct ID: Hashable, Sendable, RawRepresentable, CustomStringConvertible {
        /// The Windows thread ID. `DWORD` is typedef'd to `UInt32`; we expose
        /// `UInt32` directly to avoid leaking the platform typedef into the
        /// public API.
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}

extension Windows.`32`.Kernel.Thread.ID {
    public var description: String { "tid(\(rawValue))" }
}

extension Windows.`32`.Kernel.Thread.ID {
    /// The ID of the calling thread.
    public static var current: Self {
        .init(rawValue: UInt32(unsafe GetCurrentThreadId()))
    }
}

#endif
