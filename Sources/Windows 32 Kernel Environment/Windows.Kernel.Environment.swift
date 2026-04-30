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

// MARK: - Windows Environment Variable Operations

extension Windows.`32`.Kernel.Environment {
    /// Gets an environment variable.
    ///
    /// - Parameters:
    ///   - name: The variable name as a null-terminated wide string.
    ///   - buffer: Buffer to receive the value.
    /// - Returns: Number of characters written (excluding null terminator).
    /// - Throws: `Windows.`32`.Kernel.Environment.Error` on failure.
    public static func get(
        name: UnsafePointer<WCHAR>,
        into buffer: UnsafeMutableBufferPointer<UInt16>
    ) throws(Windows.`32`.Kernel.Environment.Error) -> Int {
        let wbuffer = UnsafeMutableRawPointer(buffer.baseAddress!).assumingMemoryBound(to: WCHAR.self)
        let result = GetEnvironmentVariableW(name, wbuffer, DWORD(buffer.count))

        if result == 0 {
            throw .current()
        }

        // If result > buffer.count, buffer was too small
        if result > buffer.count {
            throw .platform(Error_Primitives.Error(code: .win32(DWORD(ERROR_INSUFFICIENT_BUFFER))))
        }

        return Int(result)
    }

    /// Gets an environment variable value.
    ///
    /// - Parameter name: The variable name as a null-terminated wide string.
    /// - Returns: The value as UTF-16 code units, or nil if not found.
    public static func get(
        name: UnsafePointer<WCHAR>
    ) -> [UInt16]? {
        // First call to get required size
        let requiredSize = GetEnvironmentVariableW(name, nil, 0)
        if requiredSize == 0 {
            return nil
        }

        var buffer = [UInt16](repeating: 0, count: Int(requiredSize))
        let result = buffer.withUnsafeMutableBufferPointer { bufferPtr in
            let wbuffer = UnsafeMutableRawPointer(bufferPtr.baseAddress!).assumingMemoryBound(to: WCHAR.self)
            return GetEnvironmentVariableW(name, wbuffer, DWORD(bufferPtr.count))
        }

        if result == 0 {
            return nil
        }

        // Trim to actual length (excluding null terminator)
        return Array(buffer.prefix(Int(result)))
    }

    /// Sets an environment variable.
    ///
    /// - Parameters:
    ///   - name: The variable name as a null-terminated wide string.
    ///   - value: The value as a null-terminated wide string.
    /// - Throws: `Windows.`32`.Kernel.Environment.Error` on failure.
    public static func set(
        name: UnsafePointer<WCHAR>,
        value: UnsafePointer<WCHAR>
    ) throws(Windows.`32`.Kernel.Environment.Error) {
        guard SetEnvironmentVariableW(name, value) else {
            throw .current()
        }
    }

    /// Unsets (removes) an environment variable.
    ///
    /// - Parameter name: The variable name as a null-terminated wide string.
    /// - Throws: `Windows.`32`.Kernel.Environment.Error` on failure.
    public static func unset(
        name: UnsafePointer<WCHAR>
    ) throws(Windows.`32`.Kernel.Environment.Error) {
        guard SetEnvironmentVariableW(name, nil) else {
            let error = GetLastError()
            if error == DWORD(ERROR_ENVVAR_NOT_FOUND) {
                return  // Already unset, not an error
            }
            throw .current()
        }
    }
}

// MARK: - Error Construction

extension Windows.`32`.Kernel.Environment.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        Self(code: Error_Primitives.Error.captureLastError())
    }
}

#endif
