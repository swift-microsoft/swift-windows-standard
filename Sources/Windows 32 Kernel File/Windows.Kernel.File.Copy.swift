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

#if os(Windows)
public import WinSDK

// MARK: - Windows.`32`.Kernel.File.Copy Namespace

extension Windows.`32`.Kernel.File {
    /// File copy operations.
    ///
    /// Wraps `CopyFileW()`. The error and options shapes mirror
    /// `ISO_9945.Kernel.File.Copy` so the L3 unifier's shared copy
    /// algorithm compiles against either platform.
    public enum Copy {}
}

// MARK: - Copy Error

extension Windows.`32`.Kernel.File.Copy {
    /// Errors that can occur during file copy operations.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Copy.Error`.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The source file does not exist.
        case sourceNotFound

        /// The destination exists and overwrite was not requested.
        case destinationExists

        /// The source or destination is a directory.
        case isDirectory

        /// Permission denied.
        case permissionDenied

        /// The underlying clone/copy operation failed.
        case clone(Windows.`32`.Kernel.File.Clone.Error)

        /// Removing an existing destination failed.
        case unlink(Windows.`32`.Kernel.File.Delete.Error)

        /// Copying attributes failed.
        case attributes(Windows.`32`.Kernel.File.Attributes.Error)

        /// Copying timestamps failed.
        case times(Windows.`32`.Kernel.File.Times.Error)

        /// Creating a directory failed.
        case mkdir(Windows.`32`.Kernel.Directory.Create.Error)

        /// Removing a directory failed.
        case rmdir(Windows.`32`.Kernel.Directory.Remove.Error)

        /// A descriptive operational failure.
        case operation(Swift.String)
    }
}

// MARK: - Semantic Accessors

extension Windows.`32`.Kernel.File.Copy.Error {
    /// Returns `true` if the error indicates the source was not found.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Copy.Error.isSourceNotFound`.
    public var isSourceNotFound: Bool {
        if case .sourceNotFound = self { return true }
        return false
    }

    /// Returns `true` if the error indicates the destination already exists.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Copy.Error.isDestinationExists`.
    public var isDestinationExists: Bool {
        if case .destinationExists = self { return true }
        return false
    }

    /// Returns `true` if the error indicates a directory was encountered.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Copy.Error.isDirectory` (the property
    /// coexists with the same-named case, as in the ISO original).
    public var isDirectory: Bool {
        if case .isDirectory = self { return true }
        return false
    }

    /// Returns `true` if the error indicates permission was denied.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Copy.Error.isPermissionDenied`.
    public var isPermissionDenied: Bool {
        if case .permissionDenied = self { return true }
        return false
    }
}

extension Windows.`32`.Kernel.File.Copy.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .sourceNotFound: return "source not found"
        case .destinationExists: return "destination already exists"
        case .isDirectory: return "is a directory"
        case .permissionDenied: return "permission denied"
        case .clone(let e): return "clone: \(e)"
        case .unlink(let e): return "unlink: \(e)"
        case .attributes(let e): return "attributes: \(e)"
        case .times(let e): return "times: \(e)"
        case .mkdir(let e): return "mkdir: \(e)"
        case .rmdir(let e): return "rmdir: \(e)"
        case .operation(let s): return "operation failed: \(s)"
        }
    }
}

// MARK: - Copy Options

extension Windows.`32`.Kernel.File.Copy {
    /// Options for copy operations. Mirrors
    /// `ISO_9945.Kernel.File.Copy.Options`.
    public struct Options: Sendable, Equatable {
        /// Overwrite an existing destination.
        public var overwrite: Bool

        /// Copy permissions/attributes to the destination.
        public var copyAttributes: Bool

        /// Follow symlinks (copy the target) rather than the link itself.
        public var followSymlinks: Bool

        public init(
            overwrite: Bool = false,
            copyAttributes: Bool = true,
            followSymlinks: Bool = true
        ) {
            self.overwrite = overwrite
            self.copyAttributes = copyAttributes
            self.followSymlinks = followSymlinks
        }
    }
}

// MARK: - Copy Operations

extension Windows.`32`.Kernel.File.Copy {
    /// Copies a file.
    ///
    /// - Parameters:
    ///   - source: The file to copy.
    ///   - destination: The destination path.
    ///   - overwrite: Whether to overwrite an existing destination.
    /// - Throws: ``Error`` on failure.
    public static func copy(
        from source: borrowing Path,
        to destination: borrowing Path,
        overwrite: Bool = false
    ) throws(Error) {
        try unsafe source.view.withUnsafePointer { srcPtr throws(Error) in
            try unsafe destination.view.withUnsafePointer { dstPtr throws(Error) in
                try copy(
                    from: srcPtr,
                    to: dstPtr,
                    overwrite: overwrite
                )
            }
        }
    }

    /// Copies a file using unsafe wide-string paths.
    ///
    /// - Parameters:
    ///   - source: The source as a null-terminated wide string.
    ///   - destination: The destination as a null-terminated wide string.
    ///   - overwrite: Whether to overwrite an existing destination.
    /// - Throws: ``Error`` on failure.
    public static func copy(
        from source: UnsafePointer<Path.Char>,
        to destination: UnsafePointer<Path.Char>,
        overwrite: Bool = false
    ) throws(Error) {
        let wSource = UnsafeRawPointer(source).assumingMemoryBound(to: WCHAR.self)
        let wDest = UnsafeRawPointer(destination).assumingMemoryBound(to: WCHAR.self)

        // CopyFileW: bFailIfExists = true means fail if destination exists
        let failIfExists = !overwrite

        guard CopyFileW(wSource, wDest, failIfExists) else {
            throw Error(fromLastError: Error_Primitives.Error.captureLastError())
        }
    }

    /// Copies file data for the clone fallback path.
    ///
    /// The syscall-layer form the L3 unifier's `Clone` consumes on Windows
    /// (which clones by copying): throws the raw ``Clone/Error/Syscall``
    /// for mapping via `Clone.Error.init(from:)` per [PLAT-ARCH-008c].
    ///
    /// - Parameters:
    ///   - source: The file to copy.
    ///   - destination: The destination path (must not exist).
    /// - Throws: `Clone.Error.Syscall` on failure.
    public static func file(
        source: borrowing Path.Borrowed,
        destination: borrowing Path.Borrowed
    ) throws(Windows.`32`.Kernel.File.Clone.Error.Syscall) {
        try unsafe source.withUnsafePointer { srcPtr throws(Windows.`32`.Kernel.File.Clone.Error.Syscall) in
            try unsafe destination.withUnsafePointer { dstPtr throws(Windows.`32`.Kernel.File.Clone.Error.Syscall) in
                let wSource = UnsafeRawPointer(srcPtr).assumingMemoryBound(to: WCHAR.self)
                let wDest = UnsafeRawPointer(dstPtr).assumingMemoryBound(to: WCHAR.self)
                guard CopyFileW(wSource, wDest, true) else {
                    throw .platform(
                        code: Error_Primitives.Error.captureLastError(),
                        operation: .copyfile
                    )
                }
            }
        }
    }
}

// MARK: - Error Mapping

extension Windows.`32`.Kernel.File.Copy.Error {
    /// Maps a captured Win32 error code to the semantic case.
    internal init(fromLastError code: Error_Primitives.Error.Code) {
        switch code {
        case _ where code == .Windows.ERROR_FILE_NOT_FOUND,
             _ where code == .Windows.ERROR_PATH_NOT_FOUND:
            self = .sourceNotFound
        case _ where code == .Windows.ERROR_FILE_EXISTS,
             _ where code == .Windows.ERROR_ALREADY_EXISTS:
            self = .destinationExists
        case _ where code == .Windows.ERROR_ACCESS_DENIED:
            self = .permissionDenied
        default:
            self = .operation("CopyFileW failed: \(code)")
        }
    }
}

#endif
