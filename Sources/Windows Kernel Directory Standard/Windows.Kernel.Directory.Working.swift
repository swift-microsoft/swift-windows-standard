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

// MARK: - Windows Working Directory Operations

extension Windows.Kernel.Directory.Working {
    /// Gets the current working directory.
    ///
    /// - Parameter buffer: Buffer to receive the path (UTF-16).
    /// - Returns: The number of characters written (excluding null terminator).
    /// - Throws: `Kernel.Directory.Working.Error` on failure.
    public static func get(
        into buffer: UnsafeMutableBufferPointer<UInt16>
    ) throws(Kernel.Directory.Working.Error) -> Int {
        let wbuffer = UnsafeMutableRawPointer(buffer.baseAddress!).assumingMemoryBound(to: WCHAR.self)
        let result = GetCurrentDirectoryW(DWORD(buffer.count), wbuffer)

        guard result != 0 else {
            throw .current()
        }

        // If result > buffer.count, the buffer was too small
        if result > buffer.count {
            throw .platform(Kernel.Error(code: .win32(DWORD(ERROR_INSUFFICIENT_BUFFER))))
        }

        return Int(result)
    }

    /// Gets the current working directory into an array.
    ///
    /// - Returns: The current directory path as UTF-16 code units.
    /// - Throws: `Kernel.Directory.Working.Error` on failure.
    public static func get() throws(Kernel.Directory.Working.Error) -> [UInt16] {
        // First call to get required size
        let requiredSize = GetCurrentDirectoryW(0, nil)
        guard requiredSize > 0 else {
            throw .current()
        }

        var buffer = [UInt16](repeating: 0, count: Int(requiredSize))
        let result = try buffer.withUnsafeMutableBufferPointer { bufferPtr in
            try get(into: bufferPtr)
        }

        // Trim to actual length (excluding null terminator)
        return Array(buffer.prefix(result))
    }

    /// Sets the current working directory.
    ///
    /// - Parameter path: The new working directory path.
    /// - Throws: `Kernel.Directory.Working.Error` on failure.
    public static func set(
        path: borrowing Kernel.Path
    ) throws(Kernel.Directory.Working.Error) {
        try path.withUnsafeCString { ptr throws(Kernel.Directory.Working.Error) in
            try set(unsafePath: ptr)
        }
    }

    /// Sets the current working directory using an unsafe wide string.
    ///
    /// - Parameter unsafePath: The path as a null-terminated wide string.
    /// - Throws: `Kernel.Directory.Working.Error` on failure.
    public static func set(
        unsafePath: UnsafePointer<Path.Char>
    ) throws(Kernel.Directory.Working.Error) {
        let wpath = UnsafeRawPointer(unsafePath).assumingMemoryBound(to: WCHAR.self)
        guard SetCurrentDirectoryW(wpath) else {
            throw .current()
        }
    }
}

// MARK: - Error Construction

extension Kernel.Directory.Working.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        Self(code: Windows.Kernel.Error.captureLastError())
    }
}

#endif
