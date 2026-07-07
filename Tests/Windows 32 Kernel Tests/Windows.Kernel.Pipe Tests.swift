// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-32 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-32 project authors
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

    extension Windows.`32`.Kernel.Pipe {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Namespace Tests

    extension Windows.`32`.Kernel.Pipe.Test.Unit {
        @Test
        func `Pipe namespace exists`() {
            _ = Windows.`32`.Kernel.Pipe.self
        }

        @Test
        func `Pipe.Descriptors type exists`() {
            _ = Windows.`32`.Kernel.Pipe.Descriptors.self
        }
    }

    // MARK: - Pipe Creation Tests

    extension Windows.`32`.Kernel.Pipe.Test.Unit {
        @Test
        func `pipe() returns valid Descriptors`() throws {
            let descriptors = try Windows.`32`.Kernel.Pipe.pipe()

            let readIsValid = descriptors.read.isValid
            #expect(readIsValid)
            let writeIsValid = descriptors.write.isValid
            #expect(writeIsValid)
        }
    }

    // MARK: - Edge Cases

    extension Windows.`32`.Kernel.Pipe.Test.EdgeCase {
        @Test
        func `create and close many pipes`() throws {
            for _ in 0..<100 {
                _ = try Windows.`32`.Kernel.Pipe.pipe()
                // descriptors deinit closes both handles via the ~Copyable
                // Descriptor's CloseHandle path.
            }
        }
    }

#endif
