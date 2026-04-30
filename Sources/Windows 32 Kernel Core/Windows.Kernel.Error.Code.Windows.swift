// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-standard open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)

extension Error_Primitives.Error.Code {
    /// Windows Win32 error constants.
    ///
    /// Named constants for common Windows error codes. Use these instead of
    /// magic numbers when matching error codes in switch statements.
    ///
    /// ## Example
    ///
    /// ```swift
    /// switch code {
    /// case .Windows.ERROR_FILE_NOT_FOUND:
    ///     // Handle "file not found"
    /// case .Windows.ERROR_ACCESS_DENIED:
    ///     // Handle "access denied"
    /// default:
    ///     break
    /// }
    /// ```
    public enum Windows {}
}

// MARK: - Path and File Errors

extension Error_Primitives.Error.Code.Windows {
    /// The system cannot find the file specified (error 2).
    @inlinable
    public static var ERROR_FILE_NOT_FOUND: Error_Primitives.Error.Code { .win32(2) }

    /// The system cannot find the path specified (error 3).
    @inlinable
    public static var ERROR_PATH_NOT_FOUND: Error_Primitives.Error.Code { .win32(3) }

    /// Access is denied (error 5).
    @inlinable
    public static var ERROR_ACCESS_DENIED: Error_Primitives.Error.Code { .win32(5) }

    /// The drive cannot find the sector requested (error 27).
    @inlinable
    public static var ERROR_SECTOR_NOT_FOUND: Error_Primitives.Error.Code { .win32(27) }

    /// The file exists (error 80).
    @inlinable
    public static var ERROR_FILE_EXISTS: Error_Primitives.Error.Code { .win32(80) }

    /// Cannot create a file when that file already exists (error 183).
    @inlinable
    public static var ERROR_ALREADY_EXISTS: Error_Primitives.Error.Code { .win32(183) }

    /// The filename or extension is too long (error 206).
    @inlinable
    public static var ERROR_FILENAME_EXCED_RANGE: Error_Primitives.Error.Code { .win32(206) }
}

// MARK: - Directory Errors

extension Error_Primitives.Error.Code.Windows {
    /// The system cannot move the file to a different disk drive (error 17).
    @inlinable
    public static var ERROR_NOT_SAME_DEVICE: Error_Primitives.Error.Code { .win32(17) }

    /// The directory is not empty (error 145).
    @inlinable
    public static var ERROR_DIR_NOT_EMPTY: Error_Primitives.Error.Code { .win32(145) }

    /// The directory name is invalid (error 267).
    @inlinable
    public static var ERROR_DIRECTORY: Error_Primitives.Error.Code { .win32(267) }
}

// MARK: - Permission Errors

extension Error_Primitives.Error.Code.Windows {
    /// The media is write protected (error 19).
    @inlinable
    public static var ERROR_WRITE_PROTECT: Error_Primitives.Error.Code { .win32(19) }

    /// The process cannot access the file because it is being used by another process (error 32).
    @inlinable
    public static var ERROR_SHARING_VIOLATION: Error_Primitives.Error.Code { .win32(32) }

    /// The process cannot access the file because another process has locked a portion of the file (error 33).
    @inlinable
    public static var ERROR_LOCK_VIOLATION: Error_Primitives.Error.Code { .win32(33) }
}

// MARK: - Invalid Path Errors

extension Error_Primitives.Error.Code.Windows {
    /// The system cannot find the drive specified (error 15).
    @inlinable
    public static var ERROR_INVALID_DRIVE: Error_Primitives.Error.Code { .win32(15) }

    /// The filename, directory name, or volume label syntax is incorrect (error 123).
    @inlinable
    public static var ERROR_INVALID_NAME: Error_Primitives.Error.Code { .win32(123) }

    /// The specified path is invalid (error 161).
    @inlinable
    public static var ERROR_BAD_PATHNAME: Error_Primitives.Error.Code { .win32(161) }
}

// MARK: - Network Errors

extension Error_Primitives.Error.Code.Windows {
    /// The network path was not found (error 53).
    @inlinable
    public static var ERROR_BAD_NETPATH: Error_Primitives.Error.Code { .win32(53) }

    /// The network name cannot be found (error 67).
    @inlinable
    public static var ERROR_BAD_NET_NAME: Error_Primitives.Error.Code { .win32(67) }
}

// MARK: - Resource Errors

extension Error_Primitives.Error.Code.Windows {
    /// Not enough storage is available to process this command (error 8).
    @inlinable
    public static var ERROR_NOT_ENOUGH_MEMORY: Error_Primitives.Error.Code { .win32(8) }

    /// There is not enough space on the disk (error 112).
    @inlinable
    public static var ERROR_DISK_FULL: Error_Primitives.Error.Code { .win32(112) }

    /// The system cannot open the file (error 4).
    @inlinable
    public static var ERROR_TOO_MANY_OPEN_FILES: Error_Primitives.Error.Code { .win32(4) }
}

// MARK: - Handle and Descriptor Errors

extension Error_Primitives.Error.Code.Windows {
    /// The handle is invalid (error 6).
    @inlinable
    public static var ERROR_INVALID_HANDLE: Error_Primitives.Error.Code { .win32(6) }
}

// MARK: - I/O Errors

extension Error_Primitives.Error.Code.Windows {
    /// Reached the end of the file (error 38).
    @inlinable
    public static var ERROR_HANDLE_EOF: Error_Primitives.Error.Code { .win32(38) }

    /// The pipe has been ended (error 109).
    @inlinable
    public static var ERROR_BROKEN_PIPE: Error_Primitives.Error.Code { .win32(109) }

    /// There is more data available (error 234).
    @inlinable
    public static var ERROR_MORE_DATA: Error_Primitives.Error.Code { .win32(234) }

    /// No data is available (error 232).
    @inlinable
    public static var ERROR_NO_DATA: Error_Primitives.Error.Code { .win32(232) }
}

// MARK: - Operation Errors

extension Error_Primitives.Error.Code.Windows {
    /// The parameter is incorrect (error 87).
    @inlinable
    public static var ERROR_INVALID_PARAMETER: Error_Primitives.Error.Code { .win32(87) }

    /// This function is not supported on this system (error 120).
    @inlinable
    public static var ERROR_CALL_NOT_IMPLEMENTED: Error_Primitives.Error.Code { .win32(120) }

    /// The request is not supported (error 50).
    @inlinable
    public static var ERROR_NOT_SUPPORTED: Error_Primitives.Error.Code { .win32(50) }
}
#endif
