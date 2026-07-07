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

    extension Windows.`32`.Kernel.Thread.Affinity {
        /// Platform support level for thread affinity.
        ///
        /// This is a 3-state capability indicator, not a boolean.
        /// Use this to inform placement decisions.
        public enum Support: Sendable, Equatable {
            /// Platform does not support thread affinity.
            ///
            /// Attempting to set affinity will fail or be ignored.
            case none

            /// Affinity is advisory only.
            ///
            /// The OS may honor the request but is not required to.
            case advisory

            /// Affinity is enforced.
            ///
            /// The thread will be pinned to the specified CPUs.
            /// Example: Linux with pthread_setaffinity_np, Windows with SetThreadAffinityMask.
            case enforced
        }
    }

#endif
