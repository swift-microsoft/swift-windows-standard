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

    extension Clock.Continuous {
        /// Returns the current instant on the continuous clock.
        ///
        /// Uses `QueryPerformanceCounter` which advances during system sleep,
        /// providing wall-clock time measurement.
        @inlinable
        public static var now: Clock.Continuous.Instant {
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

            let ns = seconds * 1_000_000_000 + (remainder * 1_000_000_000) / frequencyValue
            return Clock.Continuous.Instant(nanoseconds: ns)
        }
    }

    extension Clock.Suspending {
        /// Returns the current instant on the suspending clock.
        ///
        /// Uses `QueryUnbiasedInterruptTime` which pauses during system sleep,
        /// measuring only active execution time.
        @inlinable
        public static var now: Clock.Suspending.Instant {
            var unbiasedTime: ULONGLONG = 0
            QueryUnbiasedInterruptTime(&unbiasedTime)

            // QueryUnbiasedInterruptTime returns 100-nanosecond intervals
            // Convert to nanoseconds by multiplying by 100
            let ns = UInt64(unbiasedTime) * 100
            return Clock.Suspending.Instant(nanoseconds: ns)
        }
    }

#endif
