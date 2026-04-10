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
import WinSDK
import Testing

@testable import Windows_Kernel_Standard
import Kernel_Descriptor_Primitives
import Kernel_Error_Primitives
import Kernel_File_Primitives
import Kernel_Memory_Primitives

extension Windows.Kernel.Memory.Allocation {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Memory.Allocation.Test.Unit {
    @Test("Memory.Allocation namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Memory.Allocation.self
    }

    @Test("Memory.Allocation.Error type exists")
    func errorTypeExists() {
        _ = Windows.Kernel.Memory.Allocation.Error.self
    }
}

// MARK: - System Info Tests

extension Windows.Kernel.Memory.Allocation.Test.Unit {
    @Test("systemPageSize returns non-zero")
    func systemPageSizeReturnsNonZero() {
        let pageSize = Windows.Kernel.Memory.Allocation.systemPageSize()
        #expect(pageSize > 0)
    }

    @Test("systemPageSize is typically 4096")
    func systemPageSizeTypically4096() {
        let pageSize = Windows.Kernel.Memory.Allocation.systemPageSize()
        // Common page sizes are 4096 or 8192
        #expect(pageSize >= 4096)
        #expect(pageSize <= 65536)  // Reasonable upper bound
    }

    @Test("system granularity exists")
    func systemGranularityExists() {
        let granularity = Windows.Kernel.Memory.Allocation.system
        #expect(granularity.rawValue > 0)
    }
}

// MARK: - Allocation Tests

extension Windows.Kernel.Memory.Allocation.Test.Unit {
    @Test("allocate with zero size throws invalidSize")
    func allocateZeroSizeThrows() {
        #expect(throws: Windows.Kernel.Memory.Allocation.Error.self) {
            _ = try Windows.Kernel.Memory.Allocation.allocate(
                size: 0,
                protection: .readWrite
            )
        }
    }

    @Test("allocate with valid size succeeds")
    func allocateValidSizeSucceeds() throws {
        let pageSize = Int(Windows.Kernel.Memory.Allocation.systemPageSize())
        let addr = try Windows.Kernel.Memory.Allocation.allocate(
            size: pageSize,
            protection: .readWrite
        )

        // Cleanup
        try Windows.Kernel.Memory.Allocation.free(addr: addr)
    }

    @Test("allocate and free round-trip")
    func allocateFreeRoundTrip() throws {
        let pageSize = Int(Windows.Kernel.Memory.Allocation.systemPageSize())

        for _ in 0..<10 {
            let addr = try Windows.Kernel.Memory.Allocation.allocate(
                size: pageSize,
                protection: .readWrite
            )
            try Windows.Kernel.Memory.Allocation.free(addr: addr)
        }
    }
}

// MARK: - Error Tests

extension Windows.Kernel.Memory.Allocation.Test.Unit {
    @Test("Error.invalidSize exists")
    func errorInvalidSizeExists() {
        let error = Windows.Kernel.Memory.Allocation.Error.invalidSize
        #expect(error == .invalidSize)
    }

    @Test("Error.alignmentNotSupported exists")
    func errorAlignmentNotSupportedExists() {
        let error = Windows.Kernel.Memory.Allocation.Error.alignmentNotSupported
        #expect(error == .alignmentNotSupported)
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Memory.Allocation.Test.EdgeCase {
    @Test("allocate large size")
    func allocateLargeSize() throws {
        // Allocate 1MB
        let size = 1024 * 1024
        let addr = try Windows.Kernel.Memory.Allocation.allocate(
            size: size,
            protection: .readWrite
        )

        // Cleanup
        try Windows.Kernel.Memory.Allocation.free(addr: addr)
    }
}

#endif
