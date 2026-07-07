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

#if os(Windows)
    public import WinSDK

    extension Windows.`32`.Kernel.Process {
        /// Exit operations namespace.
        public enum Exit {}
    }

    extension Windows.`32`.Kernel.Process.Exit {
        /// Terminates the calling process immediately.
        ///
        /// - Parameter exitCode: Exit code for the process (`UINT`).
        ///
        /// ## Important
        ///
        /// - This function does NOT return.
        /// - Uses `ExitProcess()` — no CRT atexit handlers, no stdio flush.
        /// - Equivalent to POSIX `_exit()`.
        ///
        /// ## Exit Code Conventions
        ///
        /// - `0`: Success
        /// - `1-255`: Application-defined errors
        ///
        /// ## Usage
        ///
        /// ```swift
        /// Windows.`32`.Kernel.Process.Exit.now(0)  // success
        /// Windows.`32`.Kernel.Process.Exit.now(1)  // failure
        /// ```
        public static func now(_ exitCode: UInt32) -> Never {
            ExitProcess(exitCode)
        }
    }

#endif
