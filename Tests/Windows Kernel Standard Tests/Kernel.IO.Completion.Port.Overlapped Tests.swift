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
    import Kernel_IO_Primitives
    import Kernel_File_Primitives

    extension Kernel.IO.Completion.Port.Overlapped {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Completion.Port.Overlapped.Test.Unit {
        @Test
        func `Overlapped type exists`() {
            _ = Kernel.IO.Completion.Port.Overlapped.self
        }

        @Test
        func `Overlapped can be zero-initialized`() {
            let overlapped = Kernel.IO.Completion.Port.Overlapped()
            _ = overlapped
        }

        @Test
        func `Overlapped offset property exists`() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            overlapped.offset = 1234
            #expect(overlapped.offset == 1234)
        }

        @Test
        func `Overlapped offset handles large values`() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            let largeValue: Int64 = 0x1_0000_0000  // 4GB
            overlapped.offset = largeValue
            #expect(overlapped.offset == largeValue)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Completion.Port.Overlapped.Test.EdgeCase {
        @Test
        func `Overlapped offset handles max Int64`() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            overlapped.offset = Int64.max
            #expect(overlapped.offset == Int64.max)
        }

        @Test
        func `Overlapped offset handles zero`() {
            var overlapped = Kernel.IO.Completion.Port.Overlapped()
            overlapped.offset = 0
            #expect(overlapped.offset == 0)
        }
    }

#endif
