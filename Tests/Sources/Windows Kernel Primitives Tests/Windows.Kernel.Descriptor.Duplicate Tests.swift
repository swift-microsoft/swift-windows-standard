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
import Testing

@testable import Windows_Kernel_Primitives
import Kernel_Primitives

extension Windows.Kernel.Dup {
    #Tests
}

// MARK: - Namespace Tests

extension Windows.Kernel.Dup.Test.Unit {
    @Test("Dup namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Dup.self
    }
}

// MARK: - Error Tests

extension Windows.Kernel.Dup.Test.Unit {
    @Test("dup with invalid descriptor throws handle error")
    func dupInvalidDescriptorThrows() {
        let invalid = Kernel.Descriptor.invalid

        #expect(throws: Kernel.Dup.Error.self) {
            _ = try Windows.Kernel.Dup.dup(invalid)
        }
    }

    @Test("dup2 with invalid source throws handle error")
    func dup2InvalidSourceThrows() {
        let invalid = Kernel.Descriptor.invalid
        let target = Kernel.Descriptor.invalid

        #expect(throws: Kernel.Dup.Error.self) {
            _ = try Windows.Kernel.Dup.dup2(invalid, to: target)
        }
    }

    @Test("dup with invalid descriptor throws handle(.invalid)")
    func dupInvalidDescriptorThrowsCorrectError() {
        let invalid = Kernel.Descriptor.invalid

        do {
            _ = try Windows.Kernel.Dup.dup(invalid)
            Issue.record("Expected error")
        } catch let error as Kernel.Dup.Error {
            if case .handle(.invalid) = error {
                // Expected
            } else {
                Issue.record("Expected .handle(.invalid), got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Dup.Test.EdgeCase {
    @Test("dup2 with invalid target still tries to dup")
    func dup2InvalidTargetTriesDup() {
        // When source is invalid but target is also invalid,
        // the source validation should happen first
        let invalid = Kernel.Descriptor.invalid

        #expect(throws: Kernel.Dup.Error.self) {
            _ = try Windows.Kernel.Dup.dup2(invalid, to: invalid)
        }
    }
}

#endif
