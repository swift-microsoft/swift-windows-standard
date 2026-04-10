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
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
public import WinSDK

// MARK: - Windows MoveFileExW syscall

// MARK: - Move Options

extension Windows.Kernel.File.Move {
    /// Options for move operations.
    public struct Options: OptionSet, Sendable {
        public let rawValue: DWORD

        public init(rawValue: DWORD) {
            self.rawValue = rawValue
        }

        /// Replace existing file at destination.
        public static let replaceExisting = Options(rawValue: DWORD(MOVEFILE_REPLACE_EXISTING))

        /// Flush buffers to disk before returning (write-through semantics).
        /// Provides durability guarantee that the rename is persisted.
        public static let writeThrough = Options(rawValue: DWORD(MOVEFILE_WRITE_THROUGH))

        /// Allow move across volumes (copy + delete).
        public static let copyAllowed = Options(rawValue: DWORD(MOVEFILE_COPY_ALLOWED))

        /// Delay move until reboot (requires privileges).
        public static let delayUntilReboot = Options(rawValue: DWORD(MOVEFILE_DELAY_UNTIL_REBOOT))
    }
}

// MARK: - Move Operations

extension Windows.Kernel.File.Move {
    /// Moves (renames) a file or directory.
    ///
    /// - Parameters:
    ///   - oldPath: The current path of the file or directory.
    ///   - newPath: The new path for the file or directory.
    ///   - replaceExisting: If true, replaces an existing file at newPath.
    /// - Throws: `Kernel.File.Move.Error` on failure.
    public static func move(
        from oldPath: borrowing Kernel.Path,
        to newPath: borrowing Kernel.Path,
        replaceExisting: Bool = false
    ) throws(Kernel.File.Move.Error) {
        let options: Options = replaceExisting ? .replaceExisting : []
        try move(from: oldPath, to: newPath, options: options)
    }

    /// Moves (renames) a file or directory with options.
    ///
    /// - Parameters:
    ///   - oldPath: The current path of the file or directory.
    ///   - newPath: The new path for the file or directory.
    ///   - options: Move options (replaceExisting, writeThrough, etc.).
    /// - Throws: `Kernel.File.Move.Error` on failure.
    public static func move(
        from oldPath: borrowing Kernel.Path,
        to newPath: borrowing Kernel.Path,
        options: Options
    ) throws(Kernel.File.Move.Error) {
        try oldPath.withUnsafeCString { oldPtr throws(Kernel.File.Move.Error) in
            try newPath.withUnsafeCString { newPtr throws(Kernel.File.Move.Error) in
                try move(
                    from: oldPtr,
                    to: newPtr,
                    options: options
                )
            }
        }
    }

    /// Moves (renames) a file or directory using unsafe wide strings.
    ///
    /// - Parameters:
    ///   - oldPath: The current path as a null-terminated wide string.
    ///   - newPath: The new path as a null-terminated wide string.
    ///   - replaceExisting: If true, replaces an existing file at newPath.
    /// - Throws: `Kernel.File.Move.Error` on failure.
    public static func move(
        from oldPath: UnsafePointer<Path.Char>,
        to newPath: UnsafePointer<Path.Char>,
        replaceExisting: Bool = false
    ) throws(Kernel.File.Move.Error) {
        let options: Options = replaceExisting ? .replaceExisting : []
        try move(from: oldPath, to: newPath, options: options)
    }

    /// Moves (renames) a file or directory using unsafe wide strings with options.
    ///
    /// - Parameters:
    ///   - oldPath: The current path as a null-terminated wide string.
    ///   - newPath: The new path as a null-terminated wide string.
    ///   - options: Move options (replaceExisting, writeThrough, etc.).
    /// - Throws: `Kernel.File.Move.Error` on failure.
    public static func move(
        from oldPath: UnsafePointer<Path.Char>,
        to newPath: UnsafePointer<Path.Char>,
        options: Options
    ) throws(Kernel.File.Move.Error) {
        let wOldPath = UnsafeRawPointer(oldPath).assumingMemoryBound(to: WCHAR.self)
        let wNewPath = UnsafeRawPointer(newPath).assumingMemoryBound(to: WCHAR.self)

        guard MoveFileExW(wOldPath, wNewPath, options.rawValue) else {
            throw .current()
        }
    }
}

// MARK: - Error Construction

extension Kernel.File.Move.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        let code = Windows.Kernel.Error.captureLastError()
        guard let win32Code = code.win32 else {
            return .platform(Kernel.Error(code: code))
        }

        switch win32Code {
        case Windows.Kernel.Error.Code.File.notFound,
             Windows.Kernel.Error.Code.File.pathNotFound:
            return .notFound
        case Windows.Kernel.Error.Code.Access.denied:
            return .permission
        case Windows.Kernel.Error.Code.File.exists,
             Windows.Kernel.Error.Code.File.alreadyExists:
            return .exists
        case Windows.Kernel.Error.Code.Access.sharingViolation:
            return .busy
        default:
            return .platform(Kernel.Error(code: code))
        }
    }
}

#endif
