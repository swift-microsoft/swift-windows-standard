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

// MARK: - Windows CreateHardLinkW syscall

extension Windows.Kernel.Link {
    /// Creates a hard link to an existing file.
    ///
    /// - Parameters:
    ///   - source: The path of the existing file.
    ///   - linkPath: The path of the hard link to create.
    /// - Throws: `Kernel.Link.Error` on failure.
    public static func create(
        source: borrowing Path,
        linkPath: borrowing Path
    ) throws(Kernel.Link.Error) {
        try source.withUnsafeCString { sourcePtr throws(Kernel.Link.Error) in
            try linkPath.withUnsafeCString { linkPtr throws(Kernel.Link.Error) in
                try create(source: sourcePtr, linkPath: linkPtr)
            }
        }
    }

    /// Creates a hard link to an existing file using unsafe wide strings.
    ///
    /// - Parameters:
    ///   - source: The source file path as a null-terminated wide string.
    ///   - linkPath: The link path as a null-terminated wide string.
    /// - Throws: `Kernel.Link.Error` on failure.
    public static func create(
        source: UnsafePointer<Path.Char>,
        linkPath: UnsafePointer<Path.Char>
    ) throws(Kernel.Link.Error) {
        let wSource = UnsafeRawPointer(source).assumingMemoryBound(to: WCHAR.self)
        let wLink = UnsafeRawPointer(linkPath).assumingMemoryBound(to: WCHAR.self)

        guard CreateHardLinkW(wLink, wSource, nil) else {
            throw .current()
        }
    }
}

// MARK: - Error Construction

extension Kernel.Link.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        let code = Error_Primitives.Error.captureLastError()
        guard let win32Code = code.win32 else {
            return .platform(Error_Primitives.Error(code: code))
        }

        switch win32Code {
        case Error_Primitives.Error.Code.File.notFound,
             Error_Primitives.Error.Code.File.pathNotFound:
            return .notFound
        case Error_Primitives.Error.Code.Access.denied:
            return .permission
        case Error_Primitives.Error.Code.File.exists,
             Error_Primitives.Error.Code.File.alreadyExists:
            return .exists
        case Error_Primitives.Error.Code.Storage.diskFull,
             Error_Primitives.Error.Code.Storage.handleDiskFull:
            return .noSpace
        default:
            return .platform(Error_Primitives.Error(code: code))
        }
    }
}

#endif
