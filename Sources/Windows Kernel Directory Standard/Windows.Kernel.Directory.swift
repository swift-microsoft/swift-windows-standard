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

// MARK: - Windows Directory Iteration

extension Windows.Kernel.Directory {
    /// A handle for iterating over directory contents.
    ///
    /// Use `open(path:)` to create an iterator, then call `next()` repeatedly
    /// until it returns `nil`. Always call `close()` when done.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var iterator = try Windows.Kernel.Directory.Iterator.open(path: dirPath)
    /// defer { iterator.close() }
    ///
    /// while let entry = try iterator.next() {
    ///     guard !entry.isDotOrDotDot else { continue }
    ///     print(entry.name ?? "<invalid name>")
    /// }
    /// ```
    public struct Iterator: ~Copyable {
        @usableFromInline
        internal var handle: HANDLE
        @usableFromInline
        internal var findData: WIN32_FIND_DATAW
        @usableFromInline
        internal var firstEntry: Bool

        @usableFromInline
        internal init(handle: HANDLE, findData: WIN32_FIND_DATAW) {
            self.handle = handle
            self.findData = findData
            self.firstEntry = true
        }

        deinit {
            if handle != INVALID_HANDLE_VALUE {
                _ = FindClose(handle)
            }
        }
    }
}

// MARK: - Iterator Operations

extension Windows.Kernel.Directory.Iterator {
    /// Opens a directory for iteration.
    ///
    /// - Parameter path: The directory path to iterate.
    /// - Returns: An iterator for the directory contents.
    /// - Throws: `Kernel.Directory.Error` on failure.
    public static func open(
        path: borrowing Kernel.Path
    ) throws(Kernel.Directory.Error) -> Self {
        try path.withUnsafeCString { ptr throws(Kernel.Directory.Error) in
            try open(unsafePath: ptr)
        }
    }

    /// Opens a directory for iteration using an unsafe wide string.
    ///
    /// - Parameter unsafePath: The directory path as a null-terminated wide string.
    /// - Returns: An iterator for the directory contents.
    /// - Throws: `Kernel.Directory.Error` on failure.
    public static func open(
        unsafePath: UnsafePointer<Kernel.Path.Char>
    ) throws(Kernel.Directory.Error) -> Self {
        // Append \* to the path for FindFirstFileW pattern
        let pathChars = unsafePath
        var length = 0
        while pathChars[length] != 0 { length += 1 }

        // Build pattern: path + \* + null
        var pattern = [UInt16](repeating: 0, count: length + 3)
        for i in 0..<length {
            pattern[i] = pathChars[i]
        }
        // Add \* if path doesn't end with \ or /
        let lastChar = length > 0 ? pattern[length - 1] : 0
        var patternLength = length
        if lastChar != 0x5C && lastChar != 0x2F {  // \ and /
            pattern[patternLength] = 0x5C  // \
            patternLength += 1
        }
        pattern[patternLength] = 0x2A  // *
        patternLength += 1
        pattern[patternLength] = 0  // null terminator

        return try pattern.withUnsafeBufferPointer { patternBuffer in
            let wpath = UnsafeRawPointer(patternBuffer.baseAddress!).assumingMemoryBound(to: WCHAR.self)

            var findData = WIN32_FIND_DATAW()
            let handle = FindFirstFileW(wpath, &findData)

            guard handle != INVALID_HANDLE_VALUE else {
                let error = GetLastError()
                throw Kernel.Directory.Error(_windowsError: error)
            }

            return Self(handle: handle, findData: findData)
        }
    }

    /// Returns the next directory entry, or `nil` if iteration is complete.
    ///
    /// - Returns: The next entry, or `nil` at end of directory.
    /// - Throws: `Kernel.Directory.Error` on I/O failure.
    public mutating func next() throws(Kernel.Directory.Error) -> Kernel.Directory.Entry? {
        if firstEntry {
            firstEntry = false
            return entryFromFindData()
        }

        guard FindNextFileW(handle, &findData) else {
            let error = GetLastError()
            if error == DWORD(ERROR_NO_MORE_FILES) {
                return nil
            }
            throw Kernel.Directory.Error(_windowsError: error)
        }

        return entryFromFindData()
    }

    /// Closes the directory iterator.
    ///
    /// Must be called when iteration is complete or abandoned.
    public consuming func close() {
        if handle != INVALID_HANDLE_VALUE {
            _ = FindClose(handle)
        }
    }

    /// Converts current findData to a Directory.Entry.
    @usableFromInline
    internal func entryFromFindData() -> Kernel.Directory.Entry {
        // Extract the name from cFileName (null-terminated)
        let nameChars = withUnsafeBytes(of: findData.cFileName) { buffer in
            let ptr = buffer.baseAddress!.assumingMemoryBound(to: UInt16.self)
            let capacity = MemoryLayout.size(ofValue: findData.cFileName) / MemoryLayout<UInt16>.size
            var length = 0
            while length < capacity && ptr[length] != 0 {
                length += 1
            }
            return Array(UnsafeBufferPointer(start: ptr, count: length))
        }

        // Determine type from attributes
        let type: Kernel.File.Stats.Kind?
        if (findData.dwFileAttributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0 {
            type = .directory
        } else if (findData.dwFileAttributes & DWORD(FILE_ATTRIBUTE_REPARSE_POINT)) != 0 {
            type = .link(.symbolic)
        } else {
            type = .regular
        }

        return Kernel.Directory.Entry(rawName: nameChars, inode: nil, type: type)
    }
}

// MARK: - Error Mapping

extension Kernel.Directory.Error {
    /// Creates an error from a Windows error code.
    internal init(_windowsError error: DWORD) {
        switch error {
        case Error_Primitives.Error.Code.File.notFound,
             Error_Primitives.Error.Code.File.pathNotFound:
            self = .notFound
        case Error_Primitives.Error.Code.Access.denied:
            self = .permission
        case Error_Primitives.Error.Code.Directory.notEmpty:
            self = .notDirectory  // Path is not a directory
        default:
            self = .platform(Error_Primitives.Error(code: .win32(error)))
        }
    }
}

#endif
