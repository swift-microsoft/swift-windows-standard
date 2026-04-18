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
import Kernel_Descriptor_Primitives
import Kernel_Error_Primitives
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Kernel_IO_Primitives
import Kernel_Thread_Primitives
import Kernel_Clock_Primitives
import Kernel_Time_Primitives
import Kernel_Random_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_System_Primitives

extension Windows.Kernel.Time {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Time.Test.Unit {
    @Test("Time namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Time.self
    }
}

// MARK: - System Time Tests

extension Windows.Kernel.Time.Test.Unit {
    @Test("systemTime returns valid FILETIME")
    func systemTimeReturnsValid() {
        let ft = Windows.Kernel.Time.systemTime()
        // FILETIME should have non-zero values (we're not in 1601)
        #expect(ft.dwHighDateTime > 0 || ft.dwLowDateTime > 0)
    }

    @Test("realtime returns reasonable value")
    func realtimeReasonable() {
        let now = Windows.Kernel.Time.realtime()
        // Should be after Jan 1, 2020 (1_577_836_800 seconds since Unix epoch).
        #expect(now.secondsSinceUnixEpoch > 1_577_836_800)
        #expect(now.nanosecondFraction >= 0)
        #expect(now.nanosecondFraction < 1_000_000_000)
    }

    @Test("realtime nanosecond fraction aligned to 100-ns boundary")
    func realtimeNanosecondAlignment() {
        // Windows FILETIME resolution is 100ns; realtime() encodes it in the
        // nanosecond field, so the nanosecond fraction is a multiple of 100.
        let now = Windows.Kernel.Time.realtime()
        #expect(now.nanosecondFraction % 100 == 0)
    }
}

#endif
