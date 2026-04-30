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
import Kernel_Primitives_Core
import Error_Primitives
import Kernel_File_Primitives
import Path_Primitives
import Kernel_IO_Primitives
import Kernel_Thread_Primitives
import Clock_Primitives
import Kernel_Time_Primitives
import Random_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import System_Primitives

extension Windows.Kernel.Close {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Close.Test.Unit {
    @Test
    func `Close namespace exists`() {
        _ = Windows.Kernel.Close.self
    }
}

// MARK: - Error Tests

extension Windows.Kernel.Close.Test.Unit {
    @Test
    func `close with invalid descriptor throws handle error`() {
        let invalid = Kernel.Descriptor.invalid

        #expect(throws: Kernel.Close.Error.self) {
            try Windows.Kernel.Close.close(invalid)
        }
    }

    @Test
    func `close with invalid descriptor throws handle(.invalid)`() {
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
    @Test
    func `Kernel.Descriptor.invalid is detected`() {
        let invalid = Kernel.Descriptor.invalid
        #expect(!invalid.isValid)
    }
}

#endif
