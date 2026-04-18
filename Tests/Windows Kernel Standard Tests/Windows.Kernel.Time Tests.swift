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

    @Test("unixTime returns reasonable value")
    func unixTimeReturnsReasonable() {
        let unix = Windows.Kernel.Time.unixTime()
        // Should be after Jan 1, 2020 (1577836800)
        #expect(unix > 1577836800)
    }

    @Test("unixTimeNanoseconds returns reasonable value")
    func unixTimeNanosecondsReturnsReasonable() {
        let nanos = Windows.Kernel.Time.unixTimeNanoseconds()
        // Should be after Jan 1, 2020 in nanoseconds
        #expect(nanos > 1577836800_000_000_000)
    }

    @Test("unixTime and unixTimeNanoseconds are consistent")
    func unixTimeConsistent() {
        let seconds = Windows.Kernel.Time.unixTime()
        let nanos = Windows.Kernel.Time.unixTimeNanoseconds()
        // The second values should match (within margin for time between calls)
        let nanosToSeconds = nanos / 1_000_000_000
        #expect(abs(nanosToSeconds - seconds) <= 1)
    }
}

#endif
