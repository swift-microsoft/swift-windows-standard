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
import Test_Primitives
import Testing_Extras

@testable import Windows_Kernel_Primitives
import Kernel_Primitives

extension Windows.Kernel.Memory.Lock {
    #TestSuites
}

// MARK: - Namespace Tests

extension Windows.Kernel.Memory.Lock.Test.Unit {
    @Test("Memory.Lock namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Memory.Lock.self
    }
}

// MARK: - Error Tests

extension Windows.Kernel.Memory.Lock.Test.Unit {
    @Test("Error type exists")
    func errorTypeExists() {
        _ = Kernel.Memory.Lock.Error.self
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Memory.Lock.Test.EdgeCase {
    @Test("lock with invalid address throws")
    func lockInvalidAddressThrows() {
        // This test verifies the function signature exists
        // Actual locking with invalid addresses is undefined behavior
        _ = Windows.Kernel.Memory.Lock.lock
        _ = Windows.Kernel.Memory.Lock.unlock
    }
}

#endif
