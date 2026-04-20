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
import Testing

    @testable import Windows_Kernel_Standard
    import Kernel_Descriptor_Primitives
    import Kernel_Error_Primitives
    import Kernel_IO_Primitives
    import Kernel_File_Primitives

    extension Kernel.IO.Completion.Port.Read.Result {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Completion.Port.Read.Result.Test.Unit {
        @Test
        func `Result type exists`() {
            _ = Kernel.IO.Completion.Port.Read.Result.self
        }

        @Test
        func `Result has pending case`() {
            let result = Kernel.IO.Completion.Port.Read.Result.pending
            if case .pending = result {
                // Expected
            } else {
                Issue.record("Expected .pending case")
            }
        }

        @Test
        func `Result has completed case`() {
            let result = Kernel.IO.Completion.Port.Read.Result.completed(bytes: 100)
            if case .completed(let bytes) = result {
                #expect(bytes == 100)
            } else {
                Issue.record("Expected .completed case")
            }
        }

        @Test
        func `Result is Sendable`() {
            let result: any Sendable = Kernel.IO.Completion.Port.Read.Result.pending
            #expect(result is Kernel.IO.Completion.Port.Read.Result)
        }

        @Test
        func `Result is Equatable`() {
            let a = Kernel.IO.Completion.Port.Read.Result.pending
            let b = Kernel.IO.Completion.Port.Read.Result.pending
            let c = Kernel.IO.Completion.Port.Read.Result.completed(bytes: 0)
            #expect(a == b)
            #expect(a != c)
        }
    }

#endif
