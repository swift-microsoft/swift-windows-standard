// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-standard open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// ISO 9945 signature parity: `Directory.open(at:) -> Stream` with
// reference-semantics iteration (non-mutating `next()`, idempotent
// `close()`, deinit fallback), mirroring the `opendir`/`readdir`/
// `closedir`-shaped `ISO_9945.Kernel.Directory.Stream` over
// `FindFirstFileW`/`FindNextFileW`/`FindClose`.

#if os(Windows)
public import WinSDK

extension Windows.`32`.Kernel.Directory {
    /// A directory stream for iteration.
    ///
    /// Mirrors `ISO_9945.Kernel.Directory.Stream`: a reference type whose
    /// `next()` and `close()` are callable on a `let` binding; `close()`
    /// is idempotent and `deinit` closes as a fallback.
    @safe
    public final class Stream: @unchecked Sendable {
        private var handle: HANDLE?
        private var findData: WIN32_FIND_DATAW
        private var firstEntry: Bool

        fileprivate init(handle: HANDLE, findData: WIN32_FIND_DATAW) {
            self.handle = handle
            self.findData = findData
            self.firstEntry = true
        }

        deinit {
            if let h = handle {
                _ = FindClose(h)
            }
        }
    }

    /// Opens a directory for iteration.
    ///
    /// Mirrors `ISO_9945.Kernel.Directory.open(at:)`.
    ///
    /// - Parameter path: The path to the directory.
    /// - Returns: A directory stream for iteration.
    /// - Throws: `Windows.`32`.Kernel.Directory.Error` on failure.
    public static func open(
        at path: borrowing Path.Borrowed
    ) throws(Error) -> Stream {
        try unsafe path.withUnsafePointer { (ptr: UnsafePointer<Path.Char>) throws(Error) in
            var findData = WIN32_FIND_DATAW()
            let handle = Iterator._findFirst(unsafePath: ptr, findData: &findData)
            guard let handle, handle != INVALID_HANDLE_VALUE else {
                throw Error(_windowsError: GetLastError())
            }
            return Stream(handle: handle, findData: findData)
        }
    }
}

// MARK: - Iteration

extension Windows.`32`.Kernel.Directory.Stream {
    /// Closes the directory stream.
    ///
    /// Idempotent; mirrors `ISO_9945.Kernel.Directory.Stream.close()`.
    public func close() {
        if let h = handle {
            _ = FindClose(h)
            handle = nil
        }
    }

    /// Returns the next entry, or nil if at end of directory.
    ///
    /// Mirrors `ISO_9945.Kernel.Directory.Stream.next()`.
    public func next() throws(Windows.`32`.Kernel.Directory.Error) -> Windows.`32`.Kernel.Directory.Entry? {
        guard let h = handle else {
            return nil
        }
        if firstEntry {
            firstEntry = false
            return Windows.`32`.Kernel.Directory.Iterator._entry(from: findData)
        }
        guard FindNextFileW(h, &findData) else {
            let error = GetLastError()
            if error == DWORD(ERROR_NO_MORE_FILES) {
                return nil
            }
            throw Windows.`32`.Kernel.Directory.Error(_windowsError: error)
        }
        return Windows.`32`.Kernel.Directory.Iterator._entry(from: findData)
    }
}

#endif
