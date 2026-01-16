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

extension Windows.Kernel.Close {
    #TestSuites
}

// MARK: - Namespace Tests

extension Windows.Kernel.Close.Test.Unit {
    @Test("Close namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Close.self
    }
}

// MARK: - Error Tests

extension Windows.Kernel.Close.Test.Unit {
    @Test("close with invalid descriptor throws handle error")
    func closeInvalidDescriptorThrows() {
        let invalid = Kernel.Descriptor.invalid

        #expect(throws: Kernel.Close.Error.self) {
            try Windows.Kernel.Close.close(invalid)
        }
    }

    @Test("close with invalid descriptor throws handle(.invalid)")
    func closeInvalidDescriptorThrowsCorrectError() {
        let invalid = Kernel.Descriptor.invalid

        do {
            try Windows.Kernel.Close.close(invalid)
            Issue.record("Expected error")
        } catch let error as Kernel.Close.Error {
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

extension Windows.Kernel.Close.Test.EdgeCase {
    @Test("Kernel.Descriptor.invalid is detected")
    func invalidDescriptorIsDetected() {
        let invalid = Kernel.Descriptor.invalid
        #expect(!invalid.isValid)
    }
}

#endif
