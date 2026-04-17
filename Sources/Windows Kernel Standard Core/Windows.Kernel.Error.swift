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
public import Kernel_Primitives_Core
public import Kernel_Descriptor_Primitives
public import Kernel_Error_Primitives
public import Kernel_File_Primitives
public import Kernel_Path_Primitives
public import Kernel_IO_Primitives
public import Kernel_Thread_Primitives
public import Kernel_Time_Primitives
public import Kernel_Random_Primitives
public import Kernel_Environment_Primitives
public import Kernel_Process_Primitives
public import Kernel_System_Primitives
public import WinSDK

extension Windows.Kernel.Error {
    /// Captures current Win32 last error as a `Kernel.Error.Code`.
    ///
    /// Must be called immediately after a failing Win32 API call, before any other API call.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let handle = CreateFileW(...)
    /// guard handle != INVALID_HANDLE_VALUE else {
    ///     throw SomeError(code: Kernel.Error.captureLastError())
    /// }
    /// ```
    @inlinable
    public static func captureLastError() -> Kernel.Error.Code {
        .win32(GetLastError())
    }
}

// MARK: - Common Win32 Error Code Constants

extension Windows.Kernel.Error {
    /// Common Win32 error codes for semantic matching.
    public enum Code {
        /// File/path errors.
        public enum File {
            /// The system cannot find the file specified.
            public static let notFound: UInt32 = UInt32(ERROR_FILE_NOT_FOUND)

            /// The system cannot find the path specified.
            public static let pathNotFound: UInt32 = UInt32(ERROR_PATH_NOT_FOUND)

            /// The file exists.
            public static let exists: UInt32 = UInt32(ERROR_FILE_EXISTS)

            /// Cannot create a file when that file already exists.
            public static let alreadyExists: UInt32 = UInt32(ERROR_ALREADY_EXISTS)
        }

        /// Access/permission errors.
        public enum Access {
            /// Access is denied.
            public static let denied: UInt32 = UInt32(ERROR_ACCESS_DENIED)

            /// The process cannot access the file because it is being used by another process.
            public static let sharingViolation: UInt32 = UInt32(ERROR_SHARING_VIOLATION)

            /// The process cannot access the file because another process has locked a portion of the file.
            public static let lockViolation: UInt32 = UInt32(ERROR_LOCK_VIOLATION)
        }

        /// Handle errors.
        public enum Handle {
            /// The handle is invalid.
            public static let invalid: UInt32 = UInt32(ERROR_INVALID_HANDLE)
        }

        /// Storage errors.
        public enum Storage {
            /// There is not enough space on the disk.
            public static let diskFull: UInt32 = UInt32(ERROR_DISK_FULL)

            /// The disk is full.
            public static let handleDiskFull: UInt32 = UInt32(ERROR_HANDLE_DISK_FULL)
        }

        /// I/O errors.
        public enum IO {
            /// The I/O operation has been aborted because of either a thread exit or an application request.
            public static let pending: UInt32 = UInt32(ERROR_IO_PENDING)

            /// Reached the end of the file.
            public static let handleEOF: UInt32 = UInt32(ERROR_HANDLE_EOF)

            /// The pipe has been ended.
            public static let brokenPipe: UInt32 = UInt32(ERROR_BROKEN_PIPE)

            /// No more data is available.
            public static let noData: UInt32 = UInt32(ERROR_NO_DATA)
        }

        /// Directory errors.
        public enum Directory {
            /// The directory is not empty.
            public static let notEmpty: UInt32 = UInt32(ERROR_DIR_NOT_EMPTY)
        }

        /// General errors.
        public enum General {
            /// The parameter is incorrect.
            public static let invalidParameter: UInt32 = UInt32(ERROR_INVALID_PARAMETER)

            /// Not enough memory resources are available to process this command.
            public static let notEnoughMemory: UInt32 = UInt32(ERROR_NOT_ENOUGH_MEMORY)

            /// The operation completed successfully.
            public static let success: UInt32 = UInt32(ERROR_SUCCESS)
        }
    }
}

#endif
