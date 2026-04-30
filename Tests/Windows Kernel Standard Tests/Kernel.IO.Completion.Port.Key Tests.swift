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

    extension Kernel.IO.Completion.Port.Key {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.IO.Completion.Port.Key.Test.Unit {
        @Test
        func `Key type exists`() {
            _ = Kernel.IO.Completion.Port.Key.self
        }

        @Test
        func `Key conforms to RawRepresentable`() {
            let key = Kernel.IO.Completion.Port.Key(rawValue: 42)
            #expect(key.rawValue == 42)
        }

        @Test
        func `Key is Sendable`() {
            let key: any Sendable = Kernel.IO.Completion.Port.Key(rawValue: 42)
            #expect(key is Kernel.IO.Completion.Port.Key)
        }

        @Test
        func `Key is Equatable`() {
            let a = Kernel.IO.Completion.Port.Key(rawValue: 42)
            let b = Kernel.IO.Completion.Port.Key(rawValue: 42)
            let c = Kernel.IO.Completion.Port.Key(rawValue: 99)
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Key is Hashable`() {
            var set = Set<Kernel.IO.Completion.Port.Key>()
            set.insert(Kernel.IO.Completion.Port.Key(rawValue: 1))
            set.insert(Kernel.IO.Completion.Port.Key(rawValue: 2))
            set.insert(Kernel.IO.Completion.Port.Key(rawValue: 1))  // duplicate
            #expect(set.count == 2)
        }

        @Test
        func `Key.zero is zero`() {
            #expect(Kernel.IO.Completion.Port.Key.zero.rawValue == 0)
        }

        @Test
        func `Key from integer literal`() {
            let key: Kernel.IO.Completion.Port.Key = 42
            #expect(key.rawValue == 42)
        }

        @Test
        func `Key from ULONG_PTR`() {
            let key = Kernel.IO.Completion.Port.Key(ULONG_PTR(123))
            #expect(key.rawValue == 123)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Completion.Port.Key.Test.EdgeCase {
        @Test
        func `Key with max value`() {
            let key = Kernel.IO.Completion.Port.Key(rawValue: ULONG_PTR.max)
            #expect(key.rawValue == ULONG_PTR.max)
        }

        @Test
        func `Key with min value`() {
            let key = Kernel.IO.Completion.Port.Key(rawValue: ULONG_PTR.min)
            #expect(key.rawValue == ULONG_PTR.min)
        }
    }

#endif
