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
@_spi(Syscall) public import Kernel_Primitives
public import WinSDK

// MARK: - Windows.Kernel.File.Copy Namespace

extension Windows.Kernel.File {
    /// File copy operations.
    public enum Copy {}
}

// MARK: - Copy Error

extension Windows.Kernel.File.Copy {
    /// Error type for file copy operations.
    public struct Error: Swift.Error, Sendable {
        public let code: Windows.Kernel.Error.Code

        public init(code: Windows.Kernel.Error.Code) {
            self.code = code
        }

        /// Source file was not found.
        public static let sourceNotFound = Error(code: .init(win32: Windows.Kernel.Error.Code.File.notFound))

        /// Destination file already exists.
        public static let destinationExists = Error(code: .init(win32: Windows.Kernel.Error.Code.File.alreadyExists))

        /// Permission denied.
        public static let permissionDenied = Error(code: .init(win32: Windows.Kernel.Error.Code.Access.denied))

        /// Creates an error from the current Win32 last error.
        @usableFromInline
        internal static func current() -> Self {
            Self(code: Windows.Kernel.Error.captureLastError())
        }
    }
}

// MARK: - Copy Operations

extension Windows.Kernel.File.Copy {
    /// Copies a file from source to destination.
    ///
    /// ## Threading
    /// This call blocks until the copy completes. Copy operations may take
    /// significant time for large files.
    ///
    /// ## Errors
    /// - Source file not found
    /// - Destination exists and overwrite is false
    /// - Permission denied
    /// - Disk full
    ///
    /// - Parameters:
    ///   - source: The source file path.
    ///   - destination: The destination file path.
    ///   - overwrite: If true, overwrites existing destination file.
    /// - Throws: `Windows.Kernel.File.Copy.Error` on failure.
    public static func copy(
        from source: borrowing Kernel.Path,
        to destination: borrowing Kernel.Path,
        overwrite: Bool = false
    ) throws(Error) {
        try source.withUnsafeCString { srcPtr throws(Error) in
            try destination.withUnsafeCString { dstPtr throws(Error) in
                try copy(
                    from: srcPtr,
                    to: dstPtr,
                    overwrite: overwrite
                )
            }
        }
    }

    /// Copies a file using unsafe wide string pointers.
    ///
    /// - Parameters:
    ///   - source: Source path as null-terminated wide string.
    ///   - destination: Destination path as null-terminated wide string.
    ///   - overwrite: If true, overwrites existing destination file.
    /// - Throws: `Windows.Kernel.File.Copy.Error` on failure.
    public static func copy(
        from source: UnsafePointer<Path.Char>,
        to destination: UnsafePointer<Path.Char>,
        overwrite: Bool = false
    ) throws(Error) {
        let wSource = UnsafeRawPointer(source).assumingMemoryBound(to: WCHAR.self)
        let wDest = UnsafeRawPointer(destination).assumingMemoryBound(to: WCHAR.self)

        // CopyFileW: bFailIfExists = true means fail if destination exists
        // So we pass !overwrite
        let failIfExists: WindowsBool = overwrite ? false : true

        guard CopyFileW(wSource, wDest, failIfExists) else {
            throw Error.current()
        }
    }
}

#endif
