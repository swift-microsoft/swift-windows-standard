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
import Kernel_Path_Primitives
import Kernel_IO_Primitives

extension Windows.Kernel.Sync {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Sync.Test.Unit {
    @Test("Sync namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Sync.self
    }
}

// MARK: - Error Tests

extension Windows.Kernel.Sync.Test.Unit {
    @Test("sync with invalid descriptor throws")
    func syncInvalidDescriptorThrows() {
        let invalid = Kernel.Descriptor.invalid

        #expect(throws: Kernel.Sync.Error.self) {
            try Windows.Kernel.Sync.sync(invalid)
        }
    }

    @Test("datasync with invalid descriptor throws")
    func datasyncInvalidDescriptorThrows() {
        let invalid = Kernel.Descriptor.invalid

        #expect(throws: Kernel.Sync.Error.self) {
            try Windows.Kernel.Sync.datasync(invalid)
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Sync.Test.EdgeCase {
    @Test("datasync is alias for sync on Windows")
    func datasyncIsAliasForSync() {
        // On Windows, datasync and sync are the same operation
        // This test just verifies both functions exist
        _ = Windows.Kernel.Sync.sync
        _ = Windows.Kernel.Sync.datasync
    }
}

#endif
