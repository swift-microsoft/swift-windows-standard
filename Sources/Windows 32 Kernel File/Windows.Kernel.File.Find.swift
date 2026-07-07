// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-32 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-32 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
    public import Pair_Primitives
    internal import WinSDK

    extension Windows.`32`.Kernel.File {
        /// Win32 file-find iteration namespace.
        ///
        /// Wraps `FindFirstFileW` / `FindNextFileW` / `FindClose` with a typed
        /// RAII Handle for safe iteration. Use ``Find/first(path:)`` to start
        /// iteration; the returned Handle owns the find resource and closes it
        /// on deinit.
        ///
        /// ## Architecture
        ///
        /// Per [PLAT-ARCH-008j], the WinSDK import lives at L2 internal scope.
        /// Public API exposes only safe types (`Handle`, `Entry`, `Error`); raw
        /// Win32 types (`HANDLE`, `WIN32_FIND_DATAW`, `DWORD`) are confined to
        /// implementation. L3 consumers compose typed L2 calls without
        /// importing WinSDK directly.
        public enum Find: Sendable {}
    }

    // MARK: - Handle (RAII for FindClose)

    extension Windows.`32`.Kernel.File.Find {
        /// A handle to an active file-find iteration, owning the underlying
        /// Win32 find handle. Closes via `FindClose` on deinit.
        ///
        /// `~Copyable` move-only ownership ensures the handle is closed exactly
        /// once. Use ``next()`` to advance the iteration.
        public struct Handle: ~Copyable, @unchecked Sendable {
            package var _raw: UnsafeMutableRawPointer

            package init(_raw: UnsafeMutableRawPointer) {
                self._raw = _raw
            }

            deinit {
                _ = unsafe FindClose(_raw)
            }
        }
    }

    // MARK: - Entry (filename + attributes snapshot)

    extension Windows.`32`.Kernel.File.Find {
        /// A single directory entry returned by file-find iteration.
        public struct Entry: Sendable {
            /// The filename (without leading path components).
            public let name: Swift.String

            internal let attributes: DWORD

            internal init(name: Swift.String, attributes: DWORD) {
                self.name = name
                self.attributes = attributes
            }
        }
    }

    extension Windows.`32`.Kernel.File.Find.Entry {
        /// Whether the entry is a directory.
        public var isDirectory: Bool {
            (attributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0
        }

        /// Whether the entry is a reparse point (symlink, junction, etc.).
        public var isReparsePoint: Bool {
            (attributes & DWORD(FILE_ATTRIBUTE_REPARSE_POINT)) != 0
        }
    }

    // MARK: - Error

    extension Windows.`32`.Kernel.File.Find {
        /// Errors returned by file-find operations.
        ///
        /// Closed error type for typed throws. Maps the 8 distinct Win32
        /// `ERROR_*` codes that file-find can return to stable categories.
        public enum Error: Swift.Error, Sendable, Hashable {
            /// Access denied (insufficient permissions or sharing violation).
            case accessDenied

            /// Path or file not found / invalid name.
            case notFound

            /// Path is not a directory.
            case notDirectory

            /// Per-process file handle limit exceeded.
            case tooManyOpenFiles

            /// Filename exceeds platform length limit.
            case nameTooLong

            /// Generic I/O failure.
            case io

            internal init(lastError: DWORD) {
                switch lastError {
                case DWORD(ERROR_ACCESS_DENIED), DWORD(ERROR_SHARING_VIOLATION):
                    self = .accessDenied
                case DWORD(ERROR_FILE_NOT_FOUND), DWORD(ERROR_PATH_NOT_FOUND), DWORD(ERROR_INVALID_NAME):
                    self = .notFound
                case DWORD(ERROR_DIRECTORY):
                    self = .notDirectory
                case DWORD(ERROR_TOO_MANY_OPEN_FILES):
                    self = .tooManyOpenFiles
                case DWORD(ERROR_FILENAME_EXCED_RANGE):
                    self = .nameTooLong
                default:
                    self = .io
                }
            }
        }
    }

    // MARK: - First (handle + first entry)

    extension Windows.`32`.Kernel.File.Find {
        /// The result of beginning a file-find iteration: the owning Handle
        /// plus the first entry.
        ///
        /// A `Pair` rather than a tuple because tuples cannot carry noncopyable
        /// elements. `Pair` is frozen, so downstream modules can consume the
        /// handle component without resilience blocking the move.
        public typealias First = Pair<Handle, Entry>
    }

    // MARK: - Iteration entry point

    extension Windows.`32`.Kernel.File.Find {
        /// Begins file-find iteration on a path pattern.
        ///
        /// The path argument is a Win32 file-find pattern, typically constructed
        /// as a directory path with trailing `\\*` (e.g., `"C:\\dir\\*"` to
        /// enumerate all entries in `C:\dir`). The platform converts the path to
        /// UTF-16 internally.
        ///
        /// - Parameter path: Win32 file-find pattern.
        /// - Returns: A ``First`` carrying the Handle (RAII for FindClose) and the first entry.
        /// - Throws: ``Error`` if the find fails.
        public static func first(path: Swift.String) throws(Error) -> First {
            var findData = WIN32_FIND_DATAW()
            let handle = unsafe withWideString(path) { wpath in
                unsafe FindFirstFileW(wpath, &findData)
            }
            guard let raw = handle, raw != INVALID_HANDLE_VALUE else {
                throw Error(lastError: GetLastError())
            }
            let entry = Entry(
                name: extractFileName(from: &findData),
                attributes: findData.dwFileAttributes
            )
            return First(Handle(_raw: raw), entry)
        }
    }

    // MARK: - Iterator advancement

    extension Windows.`32`.Kernel.File.Find.Handle {
        /// Advances the iteration. Returns the next entry, or `nil` if exhausted.
        ///
        /// `nil` indicates either a clean end of iteration (no more files) OR a
        /// runtime failure during enumeration; this matches `FindNextFileW`'s
        /// API shape, which returns `false` for both cases. Callers requiring
        /// error introspection MUST check `GetLastError` themselves; for the
        /// typical glob-traversal use case, treating `nil` as "iteration end"
        /// is correct.
        public mutating func next() -> Windows.`32`.Kernel.File.Find.Entry? {
            var findData = WIN32_FIND_DATAW()
            guard unsafe FindNextFileW(_raw, &findData) else {
                return nil
            }
            return .init(
                name: extractFileName(from: &findData),
                attributes: findData.dwFileAttributes
            )
        }
    }

    // MARK: - Path existence

    extension Windows.`32`.Kernel.File {
        /// Returns `true` if a file or directory exists at the given path.
        ///
        /// Wraps `GetFileAttributesW`, treating `INVALID_FILE_ATTRIBUTES` as the
        /// "does not exist" sentinel.
        public static func pathExists(_ path: Swift.String) -> Bool {
            unsafe withWideString(path) { wpath in
                unsafe GetFileAttributesW(wpath) != INVALID_FILE_ATTRIBUTES
            }
        }
    }

    // MARK: - File-private UTF-16 helpers

    /// Calls `body` with a null-terminated UTF-16 (`WCHAR*`) buffer for the
    /// given Swift String. The buffer is valid only for the duration of the call.
    private func withWideString<R>(
        _ string: Swift.String,
        _ body: (UnsafePointer<WCHAR>) -> R
    ) -> R {
        var utf16 = Array(string.utf16)
        utf16.append(0)
        return unsafe utf16.withUnsafeBufferPointer { buffer in
            unsafe buffer.baseAddress!.withMemoryRebound(
                to: WCHAR.self,
                capacity: buffer.count
            ) { wcharPtr in
                body(wcharPtr)
            }
        }
    }

    /// Extracts a Swift String from `WIN32_FIND_DATAW.cFileName` (a UTF-16
    /// 260-element fixed array, NUL-terminated within bounds).
    private func extractFileName(from findData: inout WIN32_FIND_DATAW) -> Swift.String {
        unsafe withUnsafePointer(to: &findData.cFileName) { ptr in
            unsafe ptr.withMemoryRebound(to: WCHAR.self, capacity: 260) { wcharPtr in
                var length = 0
                while length < 260, unsafe wcharPtr[length] != 0 {
                    length += 1
                }
                let buffer = unsafe UnsafeBufferPointer(start: wcharPtr, count: length)
                return unsafe Swift.String(decoding: buffer, as: UTF16.self)
            }
        }
    }

#endif
