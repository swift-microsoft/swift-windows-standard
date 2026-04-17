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
public import WinSDK

// MARK: - Windows Clock Operations

extension Kernel.Clock.Continuous {
    /// Returns the current continuous time in nanoseconds since boot.
    ///
    /// Uses `QueryPerformanceCounter` which advances during system sleep,
    /// providing wall-clock time measurement.
    @inlinable
    public static func now() -> UInt64 {
        var counter = LARGE_INTEGER()
        var frequency = LARGE_INTEGER()
        QueryPerformanceCounter(&counter)
        QueryPerformanceFrequency(&frequency)

        // Convert to nanoseconds: (counter * 1_000_000_000) / frequency
        // Use 128-bit arithmetic to avoid overflow
        let counterValue = UInt64(bitPattern: counter.QuadPart)
        let frequencyValue = UInt64(bitPattern: frequency.QuadPart)

        // Split into high and low parts to avoid overflow
        let seconds = counterValue / frequencyValue
        let remainder = counterValue % frequencyValue

        return seconds * 1_000_000_000 + (remainder * 1_000_000_000) / frequencyValue
    }
}

extension Kernel.Clock.Suspending {
    /// Returns the current suspending time in nanoseconds since boot.
    ///
    /// Uses `QueryUnbiasedInterruptTime` which pauses during system sleep,
    /// measuring only active execution time.
    @inlinable
    public static func now() -> UInt64 {
        var unbiasedTime: ULONGLONG = 0
        QueryUnbiasedInterruptTime(&unbiasedTime)

        // QueryUnbiasedInterruptTime returns 100-nanosecond intervals
        // Convert to nanoseconds by multiplying by 100
        return UInt64(unbiasedTime) * 100
    }
}

#endif
