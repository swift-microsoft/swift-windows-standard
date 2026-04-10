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
public import Loader_Primitives
public import WinSDK

// MARK: - Windows Loader Error Utilities

/// Captures the current Win32 last error as a Loader.Message.
///
/// Must be called immediately after a failing Win32 API call.
@usableFromInline
internal func captureLastErrorMessage() -> Loader.Message {
    let errorCode = GetLastError()

    var buffer: LPWSTR?
    let length = FormatMessageW(
        DWORD(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS),
        nil,
        errorCode,
        0,  // Default language
        unsafeBitCast(&buffer, to: LPWSTR.self),
        0,
        nil
    )

    defer {
        if let buffer {
            LocalFree(buffer)
        }
    }

    if length > 0, let buffer {
        // Convert wide string to Swift String
        var message = String(decodingCString: buffer, as: UTF16.self)
        // Remove trailing newline/carriage return
        while message.hasSuffix("\r") || message.hasSuffix("\n") {
            message.removeLast()
        }
        return Loader.Message("(error \(errorCode)) \(message)")
    } else {
        return Loader.Message("Win32 error code \(errorCode)")
    }
}

// MARK: - Common Loader Error Codes

extension Windows.Loader {
    /// Common Win32 error codes for loader operations.
    public enum ErrorCode {
        /// The specified module could not be found.
        public static let moduleNotFound: DWORD = DWORD(ERROR_MOD_NOT_FOUND)

        /// The specified procedure could not be found.
        public static let procNotFound: DWORD = DWORD(ERROR_PROC_NOT_FOUND)

        /// %1 is not a valid Win32 application.
        public static let badExeFormat: DWORD = DWORD(ERROR_BAD_EXE_FORMAT)

        /// The specified path is invalid.
        public static let badPathname: DWORD = DWORD(ERROR_BAD_PATHNAME)

        /// Access is denied.
        public static let accessDenied: DWORD = DWORD(ERROR_ACCESS_DENIED)

        /// The system cannot find the file specified.
        public static let fileNotFound: DWORD = DWORD(ERROR_FILE_NOT_FOUND)

        /// The system cannot find the path specified.
        public static let pathNotFound: DWORD = DWORD(ERROR_PATH_NOT_FOUND)
    }
}

#endif
