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

// MARK: - Windows File Time Operations

extension Windows.Kernel.File.Times {
    /// Sets file times (creation, access, modification).
    ///
    /// This is the Windows equivalent of POSIX `utimensat()`.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - creationTime: New creation time, or nil to leave unchanged.
    ///   - lastAccessTime: New last access time, or nil to leave unchanged.
    ///   - lastWriteTime: New last write time, or nil to leave unchanged.
    /// - Throws: `Kernel.File.Times.Error` on failure.
    public static func setTimes(
        _ descriptor: Kernel.Descriptor,
        creationTime: FILETIME? = nil,
        lastAccessTime: FILETIME? = nil,
        lastWriteTime: FILETIME? = nil
    ) throws(Kernel.File.Times.Error) {
        var creation = creationTime
        var access = lastAccessTime
        var write = lastWriteTime

        let success = withUnsafePointer(to: &creation) { creationPtr in
            withUnsafePointer(to: &access) { accessPtr in
                withUnsafePointer(to: &write) { writePtr in
                    SetFileTime(
                        descriptor.handle,
                        creationTime != nil ? creationPtr.pointee.map { withUnsafePointer(to: $0) { $0 } } ?? nil : nil,
                        lastAccessTime != nil ? accessPtr.pointee.map { withUnsafePointer(to: $0) { $0 } } ?? nil : nil,
                        lastWriteTime != nil ? writePtr.pointee.map { withUnsafePointer(to: $0) { $0 } } ?? nil : nil
                    )
                }
            }
        }

        guard success else {
            throw .platform(Kernel.Error(code: Windows.Kernel.Error.captureLastError()))
        }
    }

    /// Sets file times using a simpler API with optional pointers.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - creationTime: Pointer to creation time, or nil to leave unchanged.
    ///   - lastAccessTime: Pointer to last access time, or nil to leave unchanged.
    ///   - lastWriteTime: Pointer to last write time, or nil to leave unchanged.
    /// - Returns: True on success, false on failure.
    @inlinable
    @discardableResult
    public static func setTimes(
        _ descriptor: Kernel.Descriptor,
        creationTime: UnsafePointer<FILETIME>?,
        lastAccessTime: UnsafePointer<FILETIME>?,
        lastWriteTime: UnsafePointer<FILETIME>?
    ) -> Bool {
        SetFileTime(
            descriptor.handle,
            creationTime,
            lastAccessTime,
            lastWriteTime
        )
    }

    /// Gets file times.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Returns: Tuple of (creationTime, lastAccessTime, lastWriteTime), or nil on failure.
    public static func getTimes(
        _ descriptor: Kernel.Descriptor
    ) -> (creation: FILETIME, access: FILETIME, write: FILETIME)? {
        var creation = FILETIME()
        var access = FILETIME()
        var write = FILETIME()

        guard GetFileTime(descriptor.handle, &creation, &access, &write) else {
            return nil
        }

        return (creation, access, write)
    }
}

// MARK: - FILETIME Helpers

extension Windows.Kernel.File {
    /// Converts a Unix timestamp (seconds since 1970) to Windows FILETIME.
    ///
    /// FILETIME is 100-nanosecond intervals since January 1, 1601 UTC.
    ///
    /// - Parameter unixTimestamp: Seconds since Unix epoch (1970-01-01).
    /// - Returns: The equivalent FILETIME.
    public static func fileTimeFromUnix(_ unixTimestamp: Int64) -> FILETIME {
        // Difference between Windows epoch (1601) and Unix epoch (1970) in 100-ns intervals
        let epochDifference: UInt64 = 116_444_736_000_000_000

        // Convert seconds to 100-ns intervals and add epoch difference
        let windowsTime = UInt64(unixTimestamp) * 10_000_000 + epochDifference

        return FILETIME(
            dwLowDateTime: DWORD(windowsTime & 0xFFFFFFFF),
            dwHighDateTime: DWORD(windowsTime >> 32)
        )
    }

    /// Converts a Windows FILETIME to Unix timestamp (seconds since 1970).
    ///
    /// - Parameter fileTime: The Windows FILETIME.
    /// - Returns: Seconds since Unix epoch (1970-01-01).
    public static func unixFromFileTime(_ fileTime: FILETIME) -> Int64 {
        // Difference between Windows epoch (1601) and Unix epoch (1970) in 100-ns intervals
        let epochDifference: UInt64 = 116_444_736_000_000_000

        let windowsTime = (UInt64(fileTime.dwHighDateTime) << 32) | UInt64(fileTime.dwLowDateTime)

        // Convert from 100-ns intervals to seconds
        return Int64((windowsTime - epochDifference) / 10_000_000)
    }

    /// Converts a Unix timestamp with nanoseconds to Windows FILETIME.
    ///
    /// - Parameters:
    ///   - seconds: Seconds since Unix epoch.
    ///   - nanoseconds: Additional nanoseconds.
    /// - Returns: The equivalent FILETIME.
    public static func fileTimeFromUnix(seconds: Int64, nanoseconds: Int64) -> FILETIME {
        // Difference between Windows epoch (1601) and Unix epoch (1970) in 100-ns intervals
        let epochDifference: UInt64 = 116_444_736_000_000_000

        // Convert to 100-ns intervals
        let windowsTime = UInt64(seconds) * 10_000_000 + UInt64(nanoseconds / 100) + epochDifference

        return FILETIME(
            dwLowDateTime: DWORD(windowsTime & 0xFFFFFFFF),
            dwHighDateTime: DWORD(windowsTime >> 32)
        )
    }

    /// Gets the current time as a FILETIME.
    ///
    /// - Returns: The current system time as FILETIME.
    public static func currentFileTime() -> FILETIME {
        var fileTime = FILETIME()
        GetSystemTimeAsFileTime(&fileTime)
        return fileTime
    }
}

// MARK: - Touch Operation

extension Windows.Kernel.File {
    /// Updates the last access and modification times to now.
    ///
    /// This is equivalent to the `touch` command.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Returns: True on success, false on failure.
    public static func touch(_ descriptor: Kernel.Descriptor) -> Bool {
        var now = FILETIME()
        GetSystemTimeAsFileTime(&now)
        return SetFileTime(descriptor.handle, nil, &now, &now)
    }
}

#endif
