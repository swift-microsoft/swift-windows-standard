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
    /// Not part of the public API — consumers use `Windows.Kernel.Time.realtime()` for
    /// typed wall-clock reads and `Clock.Continuous.now` for monotonic
    /// readings.
    package static func systemTimeRaw() -> UInt64 {
        var fileTime = FILETIME()
        GetSystemTimeAsFileTime(&fileTime)
        return UInt64(fileTime.dwHighDateTime) << 32 | UInt64(fileTime.dwLowDateTime)
    }

    /// Gets the current wall-clock time as a typed `Windows.Kernel.Time`.
    ///
    /// Uses `GetSystemTimeAsFileTime` which tracks real-world UTC time.
    /// Subject to clock adjustments — NOT suitable for elapsed time measurement.
    /// Use for timestamps and record-keeping.
    ///
    /// - Returns: The current wall-clock reading as seconds and nanoseconds
    ///   since 1970-01-01 00:00:00 UTC (100-ns precision, zero-padded to the
    ///   nanosecond slot).
    public static func realtime() -> Windows.Kernel.Time {
        // FILETIME is 100-ns intervals since 1601-01-01 UTC.
        // Unix epoch starts 1970-01-01 UTC; the difference is
        // 116_444_736_000_000_000 intervals (11_644_473_600 seconds).
        let windowsEpochDiff: UInt64 = 116_444_736_000_000_000
        let intervals = systemTimeRaw()
        let sinceUnix = intervals - windowsEpochDiff
        return Windows.Kernel.Time(
            __unchecked: (),
            secondsSinceUnixEpoch: Int64(sinceUnix / 10_000_000),
            nanosecondFraction: Int32(sinceUnix % 10_000_000) * 100
        )
    }
}

#endif
