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

public import Windows_Standard_Core
#if os(Windows)
import CWindowsMemoryShim
#endif

extension Windows_Standard_Core.Windows.Memory.Allocation {
    /// Memory allocation statistics for Windows.
    ///
    /// Uses Windows heap query APIs to capture allocation state.
    public struct Statistics: Sendable, Equatable {
        /// Number of allocations.
        public let allocations: Int

        /// Number of deallocations.
        public let deallocations: Int

        /// Total bytes allocated.
        public let bytesAllocated: Int

        /// Initialize allocation statistics.
        ///
        /// - Parameters:
        ///   - allocations: Number of allocations.
        ///   - deallocations: Number of deallocations.
        ///   - bytesAllocated: Total bytes allocated.
        public init(allocations: Int = 0, deallocations: Int = 0, bytesAllocated: Int = 0) {
            self.allocations = allocations
            self.deallocations = deallocations
            self.bytesAllocated = bytesAllocated
        }
    }
}

extension Windows_Standard_Core.Windows.Memory.Allocation.Statistics {
    /// Capture current allocation statistics.
    ///
    /// Uses Windows heap query APIs to retrieve memory allocation
    /// information from the process.
    ///
    /// - Returns: Current allocation statistics.
    public static func capture() -> Self {
        #if os(Windows)
        let stats = windows_heap_statistics()
        return Self(
            allocations: Int(stats.allocations),
            deallocations: Int(stats.deallocations),
            bytesAllocated: Int(stats.bytes_allocated)
        )
        #else
        return Self()
        #endif
    }
}
