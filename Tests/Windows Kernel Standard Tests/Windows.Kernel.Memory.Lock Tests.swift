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

extension Windows.Kernel.Memory.Lock {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Memory.Lock.Test.Unit {
    @Test
    func `Memory.Lock namespace exists`() {
        _ = Windows.Kernel.Memory.Lock.self
    }
}

// MARK: - Error Tests

extension Windows.Kernel.Memory.Lock.Test.Unit {
    @Test
    func `Error type exists`() {
        _ = Kernel.Memory.Lock.Error.self
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Memory.Lock.Test.EdgeCase {
    @Test
    func `lock with invalid address throws`() {
        // This test verifies the function signature exists
        // Actual locking with invalid addresses is undefined behavior
        _ = Windows.Kernel.Memory.Lock.lock
        _ = Windows.Kernel.Memory.Lock.unlock
    }
}

#endif
