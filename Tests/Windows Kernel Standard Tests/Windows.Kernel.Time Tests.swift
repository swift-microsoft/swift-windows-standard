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

    @Test("systemTimeRaw returns non-zero")
    func systemTimeRawReturnsNonZero() {
        let raw = Windows.Kernel.Time.systemTimeRaw()
        #expect(raw > 0)
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

// MARK: - Performance Counter Tests

extension Windows.Kernel.Time.Test.Unit {
    @Test("performanceCounter returns value")
    func performanceCounterReturnsValue() {
        let counter = Windows.Kernel.Time.performanceCounter()
        #expect(counter >= 0)
    }

    @Test("performanceFrequency returns positive value")
    func performanceFrequencyReturnsPositive() {
        let freq = Windows.Kernel.Time.performanceFrequency()
        #expect(freq > 0)
    }

    @Test("performanceCounter increases")
    func performanceCounterIncreases() {
        let c1 = Windows.Kernel.Time.performanceCounter()
        // Do something to pass time
        for _ in 0..<1000 { _ = 1 + 1 }
        let c2 = Windows.Kernel.Time.performanceCounter()
        #expect(c2 >= c1)
    }

    @Test("elapsedNanoseconds computes correctly")
    func elapsedNanosecondsComputes() {
        let start = Windows.Kernel.Time.performanceCounter()
        Sleep(10)  // Sleep 10ms
        let end = Windows.Kernel.Time.performanceCounter()

        let elapsed = Windows.Kernel.Time.elapsedNanoseconds(from: start, to: end)
        // Should be at least 9ms (allowing for timing variation)
        #expect(elapsed >= 9_000_000)
    }
}

// MARK: - Tick Count Tests

extension Windows.Kernel.Time.Test.Unit {
    @Test("tickCount returns value")
    func tickCountReturnsValue() {
        let count = Windows.Kernel.Time.tickCount()
        // System has been running, so should be non-zero
        #expect(count > 0)
    }

    @Test("tickCount64 returns value")
    func tickCount64ReturnsValue() {
        let count = Windows.Kernel.Time.tickCount64()
        #expect(count > 0)
    }

    @Test("tickCount64 >= tickCount")
    func tickCount64GreaterOrEqual() {
        let count32 = Windows.Kernel.Time.tickCount()
        let count64 = Windows.Kernel.Time.tickCount64()
        // 64-bit version should be >= 32-bit (unless wrapping)
        #expect(count64 >= UInt64(count32) || count32 > 0xF0000000)  // Allow for near-wrap
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Time.Test.EdgeCase {
    @Test("systemTimeRaw matches systemTime")
    func systemTimeRawMatchesSystemTime() {
        let ft = Windows.Kernel.Time.systemTime()
        let raw = Windows.Kernel.Time.systemTimeRaw()

        let ftAsRaw = UInt64(ft.dwHighDateTime) << 32 | UInt64(ft.dwLowDateTime)
        // Should be very close (within a few ticks for time between calls)
        #expect(abs(Int64(raw) - Int64(ftAsRaw)) < 10000)
    }
}

#endif
