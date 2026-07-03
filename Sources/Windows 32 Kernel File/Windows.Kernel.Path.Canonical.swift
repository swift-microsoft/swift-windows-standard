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
internal import WinSDK

// MARK: - Windows GetFullPathNameW syscall

extension Path.Canonical {
    /// Resolves a path to its canonical (absolute) form.
    ///
    /// - Parameters:
    ///   - path: The path to resolve.
    ///   - buffer: Buffer to receive the canonical path (UTF-16).
    /// - Returns: The number of characters written (excluding null terminator).
    /// - Throws: `Path.Canonical.Error` on failure.
    public static func resolve(
        path: borrowing Path,
        into buffer: UnsafeMutableBufferPointer<UInt16>
    ) throws(Path.Canonical.Error) -> Int {
        try unsafe path.view.withUnsafePointer { ptr throws(Path.Canonical.Error) in
            try resolve(unsafePath: ptr, into: buffer)
        }
    }

    /// Resolves a path to its canonical form using an unsafe wide string.
    ///
    /// - Parameters:
    ///   - unsafePath: The path as a null-terminated wide string.
    ///   - buffer: Buffer to receive the canonical path (UTF-16).
    /// - Returns: The number of characters written (excluding null terminator).
    /// - Throws: `Path.Canonical.Error` on failure.
    public static func resolve(
        unsafePath: UnsafePointer<Path.Char>,
        into buffer: UnsafeMutableBufferPointer<UInt16>
    ) throws(Path.Canonical.Error) -> Int {
        let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
        let wbuffer = UnsafeMutableRawPointer(buffer.baseAddress!).assumingMemoryBound(to: WCHAR.self)

        let result = GetFullPathNameW(wpath, DWORD(buffer.count), wbuffer, nil)

        guard result > 0 else {
            throw .current()
        }

        // If result > buffer.count, the buffer was too small
        if result > buffer.count {
            throw .platform(Error_Primitives.Error(code: .win32(DWORD(ERROR_INSUFFICIENT_BUFFER))))
        }

        return Int(result)
    }

    /// Resolves a path to its canonical form, returning an array.
    ///
    /// - Parameter path: The path to resolve.
    /// - Returns: The canonical path as UTF-16 code units.
    /// - Throws: `Path.Canonical.Error` on failure.
    public static func resolve(
        path: borrowing Path
    ) throws(Path.Canonical.Error) -> [UInt16] {
        try unsafe path.view.withUnsafePointer { ptr throws(Path.Canonical.Error) in
            try resolve(unsafePath: ptr)
        }
    }

    /// Resolves a path to its canonical form using an unsafe wide string.
    ///
    /// - Parameter unsafePath: The path as a null-terminated wide string.
    /// - Returns: The canonical path as UTF-16 code units.
    /// - Throws: `Path.Canonical.Error` on failure.
    public static func resolve(
        unsafePath: UnsafePointer<Path.Char>
    ) throws(Path.Canonical.Error) -> [UInt16] {
        let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)

        // First call to get required size
        let requiredSize = GetFullPathNameW(wpath, 0, nil, nil)
        guard requiredSize > 0 else {
            throw .current()
        }

        var buffer = [UInt16](repeating: 0, count: Int(requiredSize))
        // Call GetFullPathNameW directly: routing through resolve(unsafePath:into:)
        // inside withUnsafeMutableBufferPointer erases the typed throw to any Error.
        let written = GetFullPathNameW(wpath, requiredSize, &buffer, nil)
        guard written > 0, written < requiredSize else {
            throw .current()
        }

        // Trim to actual length (excluding null terminator)
        return Array(buffer.prefix(Int(written)))
    }
}

// MARK: - Error Construction

extension Path.Canonical.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        let code = Error_Primitives.Error.captureLastError()
        if let e = Path.Resolution.Error(code: code) {
            return .path(e)
        }
        return .platform(Error_Primitives.Error(code: code))
    }
}

#endif
