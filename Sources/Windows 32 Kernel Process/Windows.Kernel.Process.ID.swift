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
    internal import WinSDK
#endif

extension Windows.`32`.Kernel.Process {
    /// Process identifier.
    ///
    /// Mirrors `ISO_9945.Kernel.Process.ID` (pid_t width: `Int32`) so the
    /// cross-platform `Kernel.Process.ID` surface is uniform. Win32 process
    /// IDs are DWORDs; values above `Int32.max` do not occur in practice
    /// (the kernel allocates PIDs well below it), and the signed carrier
    /// preserves POSIX sentinel semantics for shared consumers.
    public struct ID: RawRepresentable, Sendable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Current Process

#if os(Windows)
    extension Windows.`32`.Kernel.Process.ID {
        /// The current process.
        ///
        /// Mirrors `ISO_9945.Kernel.Process.ID.current` (`getpid`) via
        /// `GetCurrentProcessId`.
        public static var current: Self {
            Self(Int32(bitPattern: GetCurrentProcessId()))
        }
    }
#endif
