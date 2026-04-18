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
    /// Package-scoped helper used to implement the typed wall-clock surface.
    /// Not part of the public API — consumers use `Kernel.Time.realtime()` for
    /// typed wall-clock reads and `Kernel.Clock.Continuous.now()` for monotonic
    /// readings.
    package static func systemTimeRaw() -> UInt64 {
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

#endif
