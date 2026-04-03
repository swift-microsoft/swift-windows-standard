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
@_spi(Syscall) public import Kernel_Primitives
public import WinSDK

// MARK: - Windows Time Operations

extension Windows.Kernel.Time {
    /// Gets the current system time as a Windows FILETIME.
    ///
    /// FILETIME is 100-nanosecond intervals since January 1, 1601 (UTC).
    ///
    /// - Returns: The current system time as FILETIME.
    public static func systemTime() -> FILETIME {
        var fileTime = FILETIME()
        GetSystemTimeAsFileTime(&fileTime)
        return fileTime
    }

    /// Gets the current system time as 100-nanosecond intervals since January 1, 1601.
    ///
    /// - Returns: The current system time as a 64-bit value.
    public static func systemTimeRaw() -> UInt64 {
        var fileTime = FILETIME()
        GetSystemTimeAsFileTime(&fileTime)
        return UInt64(fileTime.dwHighDateTime) << 32 | UInt64(fileTime.dwLowDateTime)
    }

    /// Gets the current system time as seconds since Unix epoch (January 1, 1970).
    ///
    /// - Returns: Seconds since Unix epoch.
    public static func unixTime() -> Int64 {
        // Windows FILETIME starts at 1601-01-01
        // Unix epoch starts at 1970-01-01
        // Difference is 11644473600 seconds or 116444736000000000 100-ns intervals
        let windowsEpochDiff: UInt64 = 116_444_736_000_000_000
        let intervals = systemTimeRaw()
        return Int64((intervals - windowsEpochDiff) / 10_000_000)
    }

    /// Gets the current system time as nanoseconds since Unix epoch.
    ///
    /// - Returns: Nanoseconds since Unix epoch.
    public static func unixTimeNanoseconds() -> Int64 {
        let windowsEpochDiff: UInt64 = 116_444_736_000_000_000
        let intervals = systemTimeRaw()
        // Each interval is 100 nanoseconds
        return Int64((intervals - windowsEpochDiff) * 100)
    }
}

// MARK: - High-Resolution Performance Counter

extension Windows.Kernel.Time {
    /// Gets the current value of the high-resolution performance counter.
    ///
    /// - Returns: The current performance counter value.
    public static func performanceCounter() -> Int64 {
        var counter: LARGE_INTEGER = LARGE_INTEGER()
        QueryPerformanceCounter(&counter)
        return counter.QuadPart
    }

    /// Gets the frequency of the performance counter.
    ///
    /// - Returns: The performance counter frequency (counts per second).
    public static func performanceFrequency() -> Int64 {
        var frequency: LARGE_INTEGER = LARGE_INTEGER()
        QueryPerformanceFrequency(&frequency)
        return frequency.QuadPart
    }

    /// Calculates elapsed nanoseconds between two performance counter values.
    ///
    /// - Parameters:
    ///   - start: The start counter value.
    ///   - end: The end counter value.
    /// - Returns: Elapsed time in nanoseconds.
    public static func elapsedNanoseconds(from start: Int64, to end: Int64) -> Int64 {
        let elapsed = end - start
        let frequency = performanceFrequency()
        // (elapsed * 1_000_000_000) / frequency, avoiding overflow
        return (elapsed / frequency) * 1_000_000_000 + ((elapsed % frequency) * 1_000_000_000) / frequency
    }
}

// MARK: - Tick Count

extension Windows.Kernel.Time {
    /// Gets the number of milliseconds since system boot.
    ///
    /// Note: This wraps around after ~49 days. Use `tickCount64()` for longer durations.
    ///
    /// - Returns: Milliseconds since system boot (wraps at ~49 days).
    public static func tickCount() -> UInt32 {
        GetTickCount()
    }

    /// Gets the number of milliseconds since system boot (64-bit).
    ///
    /// - Returns: Milliseconds since system boot.
    public static func tickCount64() -> UInt64 {
        GetTickCount64()
    }
}

#endif
