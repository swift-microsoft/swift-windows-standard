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
internal import String_Primitives

// MARK: - Windows Loader Error Utilities

/// Captures the current Win32 last error as a Loader.Message.
///
/// Must be called immediately after a failing Win32 API call.
@usableFromInline
internal func captureLastErrorMessage() -> Loader.Message {
    let errorCode = GetLastError()

    // FORMAT_MESSAGE_ALLOCATE_BUFFER makes FormatMessageW treat the lpBuffer slot as
    // `LPWSTR*`: it allocates a buffer and writes its address into `buffer`. The
    // `(LPWSTR)&buffer` cast is expressed via unsafeBitCast of the inout address.
    var buffer: LPWSTR?
    let length = withUnsafeMutablePointer(to: &buffer) { bufferSlot in
        unsafe FormatMessageW(
            DWORD(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS),
            nil,
            errorCode,
            0,  // Default language
            unsafe unsafeBitCast(bufferSlot, to: LPWSTR.self),
            0,
            nil
        )
    }

    defer {
        if let buffer {
            unsafe LocalFree(buffer)
        }
    }

    guard length > 0, let buffer else {
        return Loader.Message(ascii: "Win32 loader error (no message text available)")
    }

    // FormatMessageW writes UTF-16. On Windows `String_Primitives.String.Char` is
    // `UInt16` (UTF-16), so the wide buffer is a `String.Char` buffer directly — no
    // transcoding. Trim the trailing CR/LF FormatMessageW appends.
    var count = Int(length)
    while count > 0, unsafe (buffer[count - 1] == 0x000D || buffer[count - 1] == 0x000A) {
        count -= 1
    }
    let view = unsafe String_Primitives.String.Borrowed(UnsafePointer(buffer), count: count)
    return unsafe Loader.Message(copying: view)
}

// MARK: - Common Loader Error Codes

extension Windows.Loader {
    /// Common Win32 error codes for loader operations.
    public enum ErrorCode {
        /// The specified module could not be found.
        package static let moduleNotFound: DWORD = DWORD(ERROR_MOD_NOT_FOUND)

        /// The specified procedure could not be found.
        package static let procNotFound: DWORD = DWORD(ERROR_PROC_NOT_FOUND)

        /// %1 is not a valid Win32 application.
        package static let badExeFormat: DWORD = DWORD(ERROR_BAD_EXE_FORMAT)

        /// The specified path is invalid.
        package static let badPathname: DWORD = DWORD(ERROR_BAD_PATHNAME)

        /// Access is denied.
        package static let accessDenied: DWORD = DWORD(ERROR_ACCESS_DENIED)

        /// The system cannot find the file specified.
        package static let fileNotFound: DWORD = DWORD(ERROR_FILE_NOT_FOUND)

        /// The system cannot find the path specified.
        package static let pathNotFound: DWORD = DWORD(ERROR_PATH_NOT_FOUND)
    }
}

#endif
