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

// MARK: - Windows System Information

extension Windows.Kernel.System {
    /// Platform path length limit.
    ///
    /// Windows has MAX_PATH (260) for legacy APIs, but modern APIs support
    /// longer paths (up to 32,767 characters with \\?\ prefix).
    /// Returns the legacy limit for compatibility.
    public static var pathMax: Kernel.System.Path.Length {
        Kernel.System.Path.Length(__unchecked: (), Cardinal(UInt(260)))  // MAX_PATH
    }

    /// Memory page size in bytes.
    ///
    /// This is the fundamental unit of memory management.
    /// Typically 4096 bytes on Windows (both x86 and ARM).
    public static var pageSize: System.Page.Size {
        var sysInfo = SYSTEM_INFO()
        GetSystemInfo(&sysInfo)
        return System.Page.Size(__unchecked: (), Cardinal(UInt(sysInfo.dwPageSize)))
    }

    /// Number of active/online processors.
    ///
    /// Uses GetSystemInfo to get the number of logical processors.
    public static var processorCount: System.Processor.Count {
        var sysInfo = SYSTEM_INFO()
        GetSystemInfo(&sysInfo)
        return System.Processor.Count(__unchecked: (), Cardinal(UInt(sysInfo.dwNumberOfProcessors)))
    }

    /// Sleeps for the specified number of nanoseconds.
    ///
    /// Note: Windows Sleep() has millisecond granularity.
    /// Sub-millisecond sleeps are rounded up to 1ms minimum.
    ///
    /// - Parameter nanoseconds: The number of nanoseconds to sleep.
    @inlinable
    public static func sleep(nanoseconds: UInt64) {
        let ms = (nanoseconds + 999_999) / 1_000_000  // Round up to milliseconds
        Sleep(DWORD(min(ms, UInt64(DWORD.max))))
    }

    /// Sleeps for the specified duration.
    ///
    /// Note: Windows Sleep() has millisecond granularity.
    ///
    /// - Parameter duration: The duration to sleep.
    @inlinable
    public static func sleep(_ duration: Duration) {
        let (seconds, attoseconds) = duration.components
        let totalMs = seconds * 1000 + attoseconds / 1_000_000_000_000_000
        Sleep(DWORD(min(totalMs, Int64(DWORD.max))))
    }
}

#endif
