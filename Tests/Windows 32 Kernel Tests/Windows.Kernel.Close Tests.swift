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
import Clock_Primitives
import Random_Primitives
import System_Primitives

extension Windows.`32`.Kernel.Close {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.`32`.Kernel.Close.Test.Unit {
    @Test
    func `Close namespace exists`() {
        _ = Windows.`32`.Kernel.Close.self
    }
}

// MARK: - Error Tests

extension Windows.`32`.Kernel.Close.Test.Unit {
    @Test
    func `close with invalid descriptor throws handle error`() {
        let invalid = Kernel.Descriptor.invalid

        do {
            try Windows.`32`.Kernel.Close.close(invalid)
            Issue.record("Expected error")
        } catch is Kernel.Close.Error {
            // Expected
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test
    func `close with invalid descriptor throws handle(.invalid)`() {
        let invalid = Kernel.Descriptor.invalid

        do {
            try Windows.`32`.Kernel.Close.close(invalid)
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

extension Windows.`32`.Kernel.Close.Test.EdgeCase {
    @Test
    func `Kernel.Descriptor.invalid is detected`() {
        let invalid = Kernel.Descriptor.invalid
        let invalidIsValid = invalid.isValid
        #expect(!invalidIsValid)
    }
}

#endif
