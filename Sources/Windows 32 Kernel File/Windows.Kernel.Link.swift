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

extension Windows.`32`.Kernel.Link {
    /// Creates a hard link to an existing file.
    ///
    /// - Parameters:
    ///   - source: The path of the existing file.
    ///   - linkPath: The path of the hard link to create.
    /// - Throws: `Windows.`32`.Kernel.Link.Error` on failure.
    public static func create(
        source: borrowing Path,
        linkPath: borrowing Path
    ) throws(Windows.`32`.Kernel.Link.Error) {
        try unsafe source.view.withUnsafePointer { sourcePtr throws(Windows.`32`.Kernel.Link.Error) in
            try unsafe linkPath.view.withUnsafePointer { linkPtr throws(Windows.`32`.Kernel.Link.Error) in
                try create(source: sourcePtr, linkPath: linkPtr)
            }
        }
    }

    /// Creates a hard link to an existing file using unsafe wide strings.
    ///
    /// - Parameters:
    ///   - source: The source file path as a null-terminated wide string.
    ///   - linkPath: The link path as a null-terminated wide string.
    /// - Throws: `Windows.`32`.Kernel.Link.Error` on failure.
    public static func create(
        source: UnsafePointer<Path.Char>,
        linkPath: UnsafePointer<Path.Char>
    ) throws(Windows.`32`.Kernel.Link.Error) {
        let wSource = UnsafeRawPointer(source).assumingMemoryBound(to: WCHAR.self)
        let wLink = UnsafeRawPointer(linkPath).assumingMemoryBound(to: WCHAR.self)

        guard CreateHardLinkW(wLink, wSource, nil) else {
            throw .current()
        }
    }
}

// MARK: - Error Construction

extension Windows.`32`.Kernel.Link.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        let code = Error_Primitives.Error.captureLastError()
        guard let win32Code = code.win32 else {
            return .platform(Error_Primitives.Error(code: code))
        }
        return current(from: win32Code)
    }

    /// Maps a Win32 error code to the semantic error (testing seam).
    package static func current(from win32Code: UInt32) -> Self {
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
            return .platform(Error_Primitives.Error(code: .win32(win32Code)))
        }
    }
}

#endif
