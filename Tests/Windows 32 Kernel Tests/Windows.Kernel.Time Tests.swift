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

    extension Windows.`32`.Kernel.Time {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Namespace Tests

    extension Windows.`32`.Kernel.Time.Test.Unit {
        @Test
        func `Time namespace exists`() {
            _ = Windows.`32`.Kernel.Time.self
        }
    }

    // MARK: - System Time Tests

    extension Windows.`32`.Kernel.Time.Test.Unit {
        @Test
        func `systemTime returns valid FILETIME`() {
            let ft = Windows.`32`.Kernel.Time.systemTime()
            // FILETIME should have non-zero values (we're not in 1601)
            #expect(ft.dwHighDateTime > 0 || ft.dwLowDateTime > 0)
        }

        @Test
        func `realtime returns reasonable value`() {
            let now = Windows.`32`.Kernel.Time.realtime()
            // Should be after Jan 1, 2020 (1_577_836_800 seconds since Unix epoch).
            #expect(now.secondsSinceUnixEpoch > 1_577_836_800)
            #expect(now.nanosecondFraction >= 0)
            #expect(now.nanosecondFraction < 1_000_000_000)
        }

        @Test
        func `realtime nanosecond fraction aligned to 100-ns boundary`() {
            // Windows FILETIME resolution is 100ns; realtime() encodes it in the
            // nanosecond field, so the nanosecond fraction is a multiple of 100.
            let now = Windows.`32`.Kernel.Time.realtime()
            #expect(now.nanosecondFraction % 100 == 0)
        }
    }

#endif
