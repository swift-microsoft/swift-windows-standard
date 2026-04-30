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
    import Error_Primitives
    import Kernel_IO_Primitives
    import Kernel_File_Primitives

    extension Kernel.IO.Completion.Port.Entry {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Completion.Port.Entry.Test.Unit {
        @Test
        func `Entry type exists`() {
            _ = Kernel.IO.Completion.Port.Entry.self
        }

        @Test
        func `Entry can be zero-initialized`() {
            let entry = Kernel.IO.Completion.Port.Entry()
            _ = entry
        }

        @Test
        func `Entry.Bytes type exists`() {
            _ = Kernel.IO.Completion.Port.Entry.Bytes.self
        }

        @Test
        func `Entry has bytes accessor`() {
            let entry = Kernel.IO.Completion.Port.Entry()
            _ = entry.bytes
        }

        @Test
        func `Entry has key accessor`() {
            let entry = Kernel.IO.Completion.Port.Entry()
            _ = entry.key
        }
    }

#endif
