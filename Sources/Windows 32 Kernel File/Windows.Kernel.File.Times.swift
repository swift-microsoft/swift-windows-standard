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

// MARK: - Windows File Time Operations (raw @_spi(Syscall))

extension Windows.Kernel.File.Times {
    /// Sets file times for a HANDLE bit pattern.
    ///
    /// Spec-literal raw `SetFileTime`. The typed L2 convenience
    /// (`set(creation:access:modification:on descriptor:)` taking
    /// `Windows.Kernel.Descriptor`) delegates to this raw SPI internally via
    /// `descriptor._rawValue`.
    ///
    /// This is the Windows equivalent of POSIX `utimensat()`.
    ///
    /// - Parameters:
    ///   - handle: HANDLE bit pattern.
    ///   - creationTime: New creation time, or nil to leave unchanged.
    ///   - lastAccessTime: New last access time, or nil to leave unchanged.
    ///   - lastWriteTime: New last write time, or nil to leave unchanged.
    /// - Throws: `Windows.Kernel.File.Times.Error` on failure.
    @_spi(Syscall)
    public static func set(
        creation creationTime: FILETIME? = nil,
        access lastAccessTime: FILETIME? = nil,
        modification lastWriteTime: FILETIME? = nil,
        on handle: UInt
    ) throws(Windows.Kernel.File.Times.Error) {
        var creation = creationTime
        var access = lastAccessTime
        var write = lastWriteTime

        let success = withUnsafePointer(to: &creation) { creationPtr in
            withUnsafePointer(to: &access) { accessPtr in
                withUnsafePointer(to: &write) { writePtr in
                    SetFileTime(
                        UnsafeMutableRawPointer(bitPattern: handle)!,
                        creationTime != nil ? creationPtr.pointee.map { withUnsafePointer(to: $0) { $0 } } ?? nil : nil,
                        lastAccessTime != nil ? accessPtr.pointee.map { withUnsafePointer(to: $0) { $0 } } ?? nil : nil,
                        lastWriteTime != nil ? writePtr.pointee.map { withUnsafePointer(to: $0) { $0 } } ?? nil : nil
                    )
                }
            }
        }

        guard success else {
            throw .platform(Error_Primitives.Error(code: Error_Primitives.Error.captureLastError()))
        }
    }

    /// Sets file times via raw FILETIME pointers on a HANDLE bit pattern.
    ///
    /// Spec-literal raw `SetFileTime`. The typed L2 convenience
    /// (`set(creation:access:modification:on descriptor:)` UnsafePointer
    /// overload taking `Windows.Kernel.Descriptor`) delegates to this raw SPI
    /// internally via `descriptor._rawValue`.
    ///
    /// - Parameters:
    ///   - handle: HANDLE bit pattern.
    ///   - creationTime: Pointer to creation time, or nil to leave unchanged.
    ///   - lastAccessTime: Pointer to last access time, or nil to leave unchanged.
    ///   - lastWriteTime: Pointer to last write time, or nil to leave unchanged.
    /// - Returns: True on success, false on failure.
    @_spi(Syscall)
    @inlinable
    @discardableResult
    public static func set(
        creation creationTime: UnsafePointer<FILETIME>?,
        access lastAccessTime: UnsafePointer<FILETIME>?,
        modification lastWriteTime: UnsafePointer<FILETIME>?,
        on handle: UInt
    ) -> Bool {
        SetFileTime(
            UnsafeMutableRawPointer(bitPattern: handle)!,
            creationTime,
            lastAccessTime,
            lastWriteTime
        )
    }

    /// Gets file times for a HANDLE bit pattern.
    ///
    /// Spec-literal raw `GetFileTime`. The typed L2 convenience
    /// (`getTimes(_:)` taking `Windows.Kernel.Descriptor`) delegates to this raw
    /// SPI internally via `descriptor._rawValue`.
    ///
    /// - Parameter handle: HANDLE bit pattern.
    /// - Returns: Tuple of (creationTime, lastAccessTime, lastWriteTime), or nil on failure.
    @_spi(Syscall)
    public static func getTimes(
        _ handle: UInt
    ) -> (creation: FILETIME, access: FILETIME, write: FILETIME)? {
        var creation = FILETIME()
        var access = FILETIME()
        var write = FILETIME()

        guard GetFileTime(UnsafeMutableRawPointer(bitPattern: handle)!, &creation, &access, &write) else {
            return nil
        }

        return (creation, access, write)
    }
}

// MARK: - Windows File Time Operations (typed convenience)

extension Windows.Kernel.File.Times {
    /// Sets file times (creation, access, modification).
    ///
    /// Typed L2 form. Delegates to the raw `set(creation:access:modification:on:)`
    /// SPI via `descriptor._rawValue`. This is the Windows equivalent of
    /// POSIX `utimensat()`.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - creationTime: New creation time, or nil to leave unchanged.
    ///   - lastAccessTime: New last access time, or nil to leave unchanged.
    ///   - lastWriteTime: New last write time, or nil to leave unchanged.
    /// - Throws: `Windows.Kernel.File.Times.Error` on failure.
    public static func set(
        creation creationTime: FILETIME? = nil,
        access lastAccessTime: FILETIME? = nil,
        modification lastWriteTime: FILETIME? = nil,
        on descriptor: Windows.Kernel.Descriptor
    ) throws(Windows.Kernel.File.Times.Error) {
        try set(
            creation: creationTime,
            access: lastAccessTime,
            modification: lastWriteTime,
            on: descriptor._rawValue
        )
    }

    /// Sets file times using a simpler API with optional pointers.
    ///
    /// Typed L2 form. Delegates to the raw `set(creation:access:modification:on:)`
    /// UnsafePointer-overload SPI via `descriptor._rawValue`.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - creationTime: Pointer to creation time, or nil to leave unchanged.
    ///   - lastAccessTime: Pointer to last access time, or nil to leave unchanged.
    ///   - lastWriteTime: Pointer to last write time, or nil to leave unchanged.
    /// - Returns: True on success, false on failure.
    @inlinable
    @discardableResult
    public static func set(
        creation creationTime: UnsafePointer<FILETIME>?,
        access lastAccessTime: UnsafePointer<FILETIME>?,
        modification lastWriteTime: UnsafePointer<FILETIME>?,
        on descriptor: Windows.Kernel.Descriptor
    ) -> Bool {
        set(
            creation: creationTime,
            access: lastAccessTime,
            modification: lastWriteTime,
            on: descriptor._rawValue
        )
    }

    /// Gets file times.
    ///
    /// Typed L2 form. Delegates to the raw `getTimes(_:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Returns: Tuple of (creationTime, lastAccessTime, lastWriteTime), or nil on failure.
    public static func getTimes(
        _ descriptor: Windows.Kernel.Descriptor
    ) -> (creation: FILETIME, access: FILETIME, write: FILETIME)? {
        getTimes(descriptor._rawValue)
    }
}

// MARK: - FILETIME Helpers

extension Windows.Kernel.File {
    /// Converts a typed `Windows.Kernel.Time` (Unix-epoch instant) to Windows FILETIME.
    ///
    /// FILETIME is 100-nanosecond intervals since January 1, 1601 UTC.
    /// The typed input is decomposed internally; callers never see raw
    /// (seconds, nanoseconds) pairs.
    ///
    /// - Parameter time: The wall-clock instant to convert.
    /// - Returns: The equivalent FILETIME.
    public static func fileTimeFromUnix(_ time: Windows.Kernel.Time) -> FILETIME {
        // Difference between Windows epoch (1601) and Unix epoch (1970) in 100-ns intervals
        let epochDifference: UInt64 = 116_444_736_000_000_000

        // Convert to 100-ns intervals
        let windowsTime =
            UInt64(time.secondsSinceUnixEpoch) * 10_000_000
            + UInt64(time.nanosecondFraction) / 100
            + epochDifference

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

    /// Gets the current time as a FILETIME.
    ///
    /// - Returns: The current system time as FILETIME.
    public static func currentFileTime() -> FILETIME {
        var fileTime = FILETIME()
        GetSystemTimeAsFileTime(&fileTime)
        return fileTime
    }
}

// MARK: - Basic Info Operations (FILE_BASIC_INFO)

extension Windows.Kernel.File {
    /// Basic file information including timestamps and attributes.
    ///
    /// This wraps the Windows `FILE_BASIC_INFO` structure for use with
    /// `GetFileInformationByHandleEx` and `SetFileInformationByHandle`.
    public struct BasicInfo: Sendable {
        /// Creation time.
        public var creationTime: LARGE_INTEGER

        /// Last access time.
        public var lastAccessTime: LARGE_INTEGER

        /// Last write time.
        public var lastWriteTime: LARGE_INTEGER

        /// Change time (metadata change time).
        public var changeTime: LARGE_INTEGER

        /// File attributes.
        public var fileAttributes: DWORD

        public init() {
            self.creationTime = LARGE_INTEGER()
            self.lastAccessTime = LARGE_INTEGER()
            self.lastWriteTime = LARGE_INTEGER()
            self.changeTime = LARGE_INTEGER()
            self.fileAttributes = 0
        }

        init(_ info: FILE_BASIC_INFO) {
            self.creationTime = info.CreationTime
            self.lastAccessTime = info.LastAccessTime
            self.lastWriteTime = info.LastWriteTime
            self.changeTime = info.ChangeTime
            self.fileAttributes = info.FileAttributes
        }

        func toFileBasicInfo() -> FILE_BASIC_INFO {
            FILE_BASIC_INFO(
                CreationTime: creationTime,
                LastAccessTime: lastAccessTime,
                LastWriteTime: lastWriteTime,
                ChangeTime: changeTime,
                FileAttributes: fileAttributes
            )
        }
    }
}

extension Windows.Kernel.File {
    /// Gets basic file information for a HANDLE bit pattern.
    ///
    /// Spec-literal raw `GetFileInformationByHandleEx` with `FileBasicInfo`.
    /// The typed L2 convenience (`getBasicInfo(_:)` taking
    /// `Windows.Kernel.Descriptor`) delegates to this raw SPI internally via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter handle: HANDLE bit pattern.
    /// - Returns: The basic file info.
    /// - Throws: Error on failure.
    @_spi(Syscall)
    public static func getBasicInfo(
        _ handle: UInt
    ) throws(Windows.Kernel.File.Stats.Error) -> BasicInfo {
        var info = FILE_BASIC_INFO()

        let success = GetFileInformationByHandleEx(
            UnsafeMutableRawPointer(bitPattern: handle)!,
            FileBasicInfo,
            &info,
            DWORD(MemoryLayout<FILE_BASIC_INFO>.size)
        )

        guard success else {
            throw .get(Error_Primitives.Error.captureLastError())
        }

        return BasicInfo(info)
    }

    /// Sets basic file information for a HANDLE bit pattern.
    ///
    /// Spec-literal raw `SetFileInformationByHandle` with `FileBasicInfo`.
    /// The typed L2 convenience (`setBasicInfo(_:_:)` taking
    /// `Windows.Kernel.Descriptor`) delegates to this raw SPI internally via
    /// `descriptor._rawValue`.
    ///
    /// - Parameters:
    ///   - handle: HANDLE bit pattern.
    ///   - info: The basic file info to set.
    /// - Throws: Error on failure.
    @_spi(Syscall)
    public static func setBasicInfo(
        _ handle: UInt,
        _ info: BasicInfo
    ) throws(Windows.Kernel.File.Attributes.Error) {
        var fileInfo = info.toFileBasicInfo()

        let success = SetFileInformationByHandle(
            UnsafeMutableRawPointer(bitPattern: handle)!,
            FileBasicInfo,
            &fileInfo,
            DWORD(MemoryLayout<FILE_BASIC_INFO>.size)
        )

        guard success else {
            throw .platform(Error_Primitives.Error(code: Error_Primitives.Error.captureLastError()))
        }
    }

    /// Gets basic file information by handle.
    ///
    /// Typed L2 form. Delegates to the raw `getBasicInfo(_:)` SPI via
    /// `descriptor._rawValue`. Retrieves timestamps and attributes using
    /// `GetFileInformationByHandleEx` with `FileBasicInfo`.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Returns: The basic file info.
    /// - Throws: Error on failure.
    public static func getBasicInfo(
        _ descriptor: Windows.Kernel.Descriptor
    ) throws(Windows.Kernel.File.Stats.Error) -> BasicInfo {
        try getBasicInfo(descriptor._rawValue)
    }

    /// Sets basic file information by handle.
    ///
    /// Typed L2 form. Delegates to the raw `setBasicInfo(_:_:)` SPI via
    /// `descriptor._rawValue`. Sets timestamps and attributes using
    /// `SetFileInformationByHandle` with `FileBasicInfo`.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - info: The basic file info to set.
    /// - Throws: Error on failure.
    public static func setBasicInfo(
        _ descriptor: Windows.Kernel.Descriptor,
        _ info: BasicInfo
    ) throws(Windows.Kernel.File.Attributes.Error) {
        try setBasicInfo(descriptor._rawValue, info)
    }

    /// Copies basic file info (timestamps and attributes) from one handle to another.
    ///
    /// This is useful for preserving metadata when copying or replacing files.
    ///
    /// - Parameters:
    ///   - source: The source file descriptor.
    ///   - destination: The destination file descriptor.
    /// - Throws: Error on failure.
    public static func copyBasicInfo(
        from source: Windows.Kernel.Descriptor,
        to destination: Windows.Kernel.Descriptor
    ) throws {
        let info = try getBasicInfo(source)
        try setBasicInfo(destination, info)
    }
}

// MARK: - Touch Operation

extension Windows.Kernel.File {
    /// Updates the last access and modification times to now on a HANDLE bit pattern.
    ///
    /// Spec-literal raw `GetSystemTimeAsFileTime + SetFileTime`. The typed
    /// L2 convenience (`touch(_:)` taking `Windows.Kernel.Descriptor`) delegates to
    /// this raw SPI internally via `descriptor._rawValue`.
    ///
    /// This is equivalent to the `touch` command.
    ///
    /// - Parameter handle: HANDLE bit pattern.
    /// - Returns: True on success, false on failure.
    @_spi(Syscall)
    public static func touch(_ handle: UInt) -> Bool {
        var now = FILETIME()
        GetSystemTimeAsFileTime(&now)
        return SetFileTime(UnsafeMutableRawPointer(bitPattern: handle)!, nil, &now, &now)
    }

    /// Updates the last access and modification times to now.
    ///
    /// Typed L2 form. Delegates to the raw `touch(_:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Returns: True on success, false on failure.
    public static func touch(_ descriptor: Windows.Kernel.Descriptor) -> Bool {
        touch(descriptor._rawValue)
    }
}

#endif
