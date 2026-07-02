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

@testable import Windows_32_Kernel
import Error_Primitives
import Path_Primitives

extension Windows.`32`.Kernel.File.Flush {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.`32`.Kernel.File.Flush.Test.Unit {
    @Test
    func `Sync namespace exists`() {
        _ = Windows.`32`.Kernel.File.Flush.self
    }
}

// MARK: - Error Tests

extension Windows.`32`.Kernel.File.Flush.Test.Unit {
    @Test
    func `sync with invalid descriptor throws`() {
        let invalid = Kernel.Descriptor.invalid

        #expect(throws: Kernel.File.Flush.Error.self) {
            try Windows.`32`.Kernel.File.Flush.flush(invalid)
        }
    }

    @Test
    func `datasync with invalid descriptor throws`() {
        let invalid = Kernel.Descriptor.invalid

        #expect(throws: Kernel.File.Flush.Error.self) {
            try Windows.`32`.Kernel.File.Flush.flushData(invalid)
        }
    }
}

// MARK: - Edge Cases

extension Windows.`32`.Kernel.File.Flush.Test.EdgeCase {
    @Test
    func `datasync is alias for sync on Windows`() {
        // On Windows, datasync and sync are the same operation
        // This test just verifies both functions exist
        _ = Windows.`32`.Kernel.File.Flush.sync
        _ = Windows.`32`.Kernel.File.Flush.datasync
    }
}

#endif
