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

// MARK: - Windows.Kernel.File.Rename Namespace

extension Windows.Kernel.File {
    /// Atomic file rename operations using SetFileInformationByHandle.
    ///
    /// This provides more control over rename semantics than MoveFileExW,
    /// including atomic replace-if-exists behavior without race conditions.
    public enum Rename {}
}

// MARK: - Rename Error

extension Windows.Kernel.File.Rename {
    /// Error type for rename operations.
    public struct Error: Swift.Error, Sendable {
        public let code: Error_Primitives.Error.Code

        public init(code: Error_Primitives.Error.Code) {
            self.code = code
        }

        /// Destination file already exists.
        public static let destinationExists = Error(code: .init(win32: Error_Primitives.Error.Code.File.alreadyExists))

        /// Permission denied.
        public static let permissionDenied = Error(code: .init(win32: Error_Primitives.Error.Code.Access.denied))

        /// File is in use by another process.
        public static let sharingViolation = Error(code: .init(win32: Error_Primitives.Error.Code.Access.sharingViolation))

        /// The operation is not supported (e.g., struct layout unavailable).
        public static let notSupported = Error(code: .init(win32: 0x32)) // ERROR_NOT_SUPPORTED

        /// Creates an error from the current Win32 last error.
        @usableFromInline
        internal static func current() -> Self {
            Self(code: Error_Primitives.Error.captureLastError())
        }

        /// Whether this error represents a transient condition that may succeed on retry.
        ///
        /// Transient errors include:
        /// - Access denied (another process may have the file open temporarily)
        /// - Sharing violation (file open with incompatible share mode)
        /// - Lock violation (file region is locked)
        public var isTransient: Bool {
            guard let win32 = code.win32 else { return false }
            switch win32 {
            case Error_Primitives.Error.Code.Access.denied,
                 Error_Primitives.Error.Code.Access.sharingViolation,
                 Error_Primitives.Error.Code.Access.lockViolation:
                return true
            default:
                return false
            }
        }

        /// Whether this error indicates the destination already exists.
        public var isDestinationExists: Bool {
            guard let win32 = code.win32 else { return false }
            switch win32 {
            case Error_Primitives.Error.Code.File.exists,
                 Error_Primitives.Error.Code.File.alreadyExists:
                return true
            default:
                return false
            }
        }
    }
}

// MARK: - Atomic Rename

extension Windows.Kernel.File.Rename {
    /// Atomically renames a file using SetFileInformationByHandle.
    ///
    /// This method opens the source file with DELETE permission, then uses
    /// SetFileInformationByHandle with FileRenameInfoEx to perform an atomic
    /// rename. This is more robust than MoveFileExW for atomic write patterns.
    ///
    /// ## Threading
    /// This call blocks until the rename completes.
    ///
    /// ## Errors
    /// - Destination exists and replaceExisting is false
    /// - Permission denied
    /// - Sharing violation (file in use)
    ///
    /// - Parameters:
    ///   - source: Path to the source file.
    ///   - destination: Path to the destination.
    ///   - replaceExisting: If true, replaces existing destination file.
    /// - Throws: `Windows.Kernel.File.Rename.Error` on failure.
    public static func atomic(
        from source: borrowing Kernel.Path,
        to destination: borrowing Kernel.Path,
        replaceExisting: Bool
    ) throws(Error) {
        try source.withUnsafeCString { srcPtr throws(Error) in
            try destination.withUnsafeCString { dstPtr throws(Error) in
                try atomic(
                    from: srcPtr,
                    to: dstPtr,
                    replaceExisting: replaceExisting
                )
            }
        }
    }

    /// Atomically renames a file using unsafe wide string pointers.
    ///
    /// - Parameters:
    ///   - source: Source path as null-terminated wide string.
    ///   - destination: Destination path as null-terminated wide string.
    ///   - replaceExisting: If true, replaces existing destination file.
    /// - Throws: `Windows.Kernel.File.Rename.Error` on failure.
    public static func atomic(
        from source: UnsafePointer<Path.Char>,
        to destination: UnsafePointer<Path.Char>,
        replaceExisting: Bool
    ) throws(Error) {
        let wSource = UnsafeRawPointer(source).assumingMemoryBound(to: WCHAR.self)
        let wDest = UnsafeRawPointer(destination).assumingMemoryBound(to: WCHAR.self)

        // Open source file with DELETE and SYNCHRONIZE permissions
        let handle = CreateFileW(
            wSource,
            DWORD(DELETE) | DWORD(SYNCHRONIZE),
            DWORD(FILE_SHARE_READ) | DWORD(FILE_SHARE_WRITE) | DWORD(FILE_SHARE_DELETE),
            nil,
            DWORD(OPEN_EXISTING),
            DWORD(FILE_FLAG_BACKUP_SEMANTICS),
            nil
        )

        guard handle != INVALID_HANDLE_VALUE else {
            throw .current()
        }
        defer { _ = CloseHandle(handle) }

        // Calculate destination path length
        var destLength = 0
        var ptr = wDest
        while ptr.pointee != 0 {
            destLength += 1
            ptr += 1
        }

        // Calculate struct offset - if unavailable, we can't proceed
        guard let fileNameOffset = MemoryLayout<FILE_RENAME_INFO>.offset(of: \.FileName) else {
            throw .notSupported
        }

        let nameByteCount = (destLength + 1) * MemoryLayout<WCHAR>.size
        let totalSize = fileNameOffset + nameByteCount

        // Allocate buffer with proper alignment
        let alignment = max(
            MemoryLayout<FILE_RENAME_INFO>.alignment,
            MemoryLayout<WCHAR>.alignment
        )
        let buffer = UnsafeMutableRawPointer.allocate(
            byteCount: totalSize,
            alignment: alignment
        )
        defer { buffer.deallocate() }

        // Initialize header portion
        let headerSize = MemoryLayout<FILE_RENAME_INFO>.size
        buffer.initializeMemory(
            as: UInt8.self,
            repeating: 0,
            count: min(headerSize, totalSize)
        )

        // Fill in the structure
        let info = buffer.assumingMemoryBound(to: FILE_RENAME_INFO.self)
        info.pointee.Flags = replaceExisting ? DWORD(FILE_RENAME_FLAG_REPLACE_IF_EXISTS) : 0
        info.pointee.RootDirectory = nil
        info.pointee.FileNameLength = DWORD(nameByteCount - MemoryLayout<WCHAR>.size)

        // Copy destination path into struct tail
        let fileNamePtr = buffer.advanced(by: fileNameOffset).assumingMemoryBound(to: WCHAR.self)
        var srcPtr = wDest
        var dstIdx = 0
        while srcPtr.pointee != 0 {
            fileNamePtr[dstIdx] = srcPtr.pointee
            srcPtr += 1
            dstIdx += 1
        }
        fileNamePtr[dstIdx] = 0 // null terminator

        // Perform the rename
        let success = SetFileInformationByHandle(
            handle,
            FileRenameInfoEx,
            buffer,
            DWORD(totalSize)
        )

        guard success else {
            throw .current()
        }
    }
}

#endif
