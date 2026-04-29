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
import Error_Primitives
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
    @Test
    func `Memory.Allocation namespace exists`() {
        _ = Windows.Kernel.Memory.Allocation.self
    }

    @Test
    func `Memory.Allocation.Error type exists`() {
        _ = Windows.Kernel.Memory.Allocation.Error.self
    }
}

// MARK: - System Info Tests

extension Windows.Kernel.Memory.Allocation.Test.Unit {
    @Test
    func `systemPageSize returns non-zero`() {
        let pageSize = Windows.Kernel.Memory.Allocation.systemPageSize()
        #expect(pageSize > 0)
    }

    @Test
    func `systemPageSize is typically 4096`() {
        let pageSize = Windows.Kernel.Memory.Allocation.systemPageSize()
        // Common page sizes are 4096 or 8192
        #expect(pageSize >= 4096)
        #expect(pageSize <= 65536)  // Reasonable upper bound
    }

    @Test
    func `system granularity exists`() {
        let granularity = Windows.Kernel.Memory.Allocation.system
        #expect(granularity.rawValue > 0)
    }
}

// MARK: - Allocation Tests

extension Windows.Kernel.Memory.Allocation.Test.Unit {
    @Test
    func `allocate with zero size throws invalidSize`() {
        #expect(throws: Windows.Kernel.Memory.Allocation.Error.self) {
            _ = try Windows.Kernel.Memory.Allocation.allocate(
                size: 0,
                protection: .readWrite
            )
        }
    }

    @Test
    func `allocate with valid size succeeds`() throws {
        let pageSize = Int(Windows.Kernel.Memory.Allocation.systemPageSize())
        let addr = try Windows.Kernel.Memory.Allocation.allocate(
            size: pageSize,
            protection: .readWrite
        )

        // Cleanup
        try Windows.Kernel.Memory.Allocation.free(addr: addr)
    }

    @Test
    func `allocate and free round-trip`() throws {
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
    @Test
    func `Error.invalidSize exists`() {
        let error = Windows.Kernel.Memory.Allocation.Error.invalidSize
        #expect(error == .invalidSize)
    }

    @Test
    func `Error.alignmentNotSupported exists`() {
        let error = Windows.Kernel.Memory.Allocation.Error.alignmentNotSupported
        #expect(error == .alignmentNotSupported)
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Memory.Allocation.Test.EdgeCase {
    @Test
    func `allocate large size`() throws {
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
