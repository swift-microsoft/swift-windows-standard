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

// MARK: - Windows File Attributes

extension Windows.Kernel.File {
    /// File attribute flags.
    ///
    /// Windows doesn't have Unix-style permissions (rwx). Instead, it uses
    /// file attributes like read-only, hidden, system, etc.
    public struct Attributes: OptionSet, Sendable {
        public let rawValue: DWORD

        public init(rawValue: DWORD) {
            self.rawValue = rawValue
        }

        /// File is read-only.
        public static let readOnly = Attributes(rawValue: DWORD(FILE_ATTRIBUTE_READONLY))

        /// File is hidden.
        public static let hidden = Attributes(rawValue: DWORD(FILE_ATTRIBUTE_HIDDEN))

        /// File is a system file.
        public static let system = Attributes(rawValue: DWORD(FILE_ATTRIBUTE_SYSTEM))

        /// File is a directory.
        public static let directory = Attributes(rawValue: DWORD(FILE_ATTRIBUTE_DIRECTORY))

        /// File is marked for archiving.
        public static let archive = Attributes(rawValue: DWORD(FILE_ATTRIBUTE_ARCHIVE))

        /// File is a device (reserved for system use).
        public static let device = Attributes(rawValue: DWORD(FILE_ATTRIBUTE_DEVICE))

        /// File has no other attributes set.
        public static let normal = Attributes(rawValue: DWORD(FILE_ATTRIBUTE_NORMAL))

        /// File is temporary.
        public static let temporary = Attributes(rawValue: DWORD(FILE_ATTRIBUTE_TEMPORARY))

        /// File is a sparse file.
        public static let sparseFile = Attributes(rawValue: DWORD(FILE_ATTRIBUTE_SPARSE_FILE))

        /// File is a reparse point (symlink, junction, etc.).
        public static let reparsePoint = Attributes(rawValue: DWORD(FILE_ATTRIBUTE_REPARSE_POINT))

        /// File is compressed.
        public static let compressed = Attributes(rawValue: DWORD(FILE_ATTRIBUTE_COMPRESSED))

        /// File data is not immediately available (offline).
        public static let offline = Attributes(rawValue: DWORD(FILE_ATTRIBUTE_OFFLINE))

        /// File is not indexed by content indexing service.
        public static let notContentIndexed = Attributes(rawValue: DWORD(FILE_ATTRIBUTE_NOT_CONTENT_INDEXED))

        /// File is encrypted.
        public static let encrypted = Attributes(rawValue: DWORD(FILE_ATTRIBUTE_ENCRYPTED))
    }
}

// MARK: - Set Attributes

extension Windows.Kernel.File {
    /// Sets file attributes by path.
    ///
    /// This is the Windows equivalent of `chmod()`, but instead of Unix
    /// permissions, it sets Windows-specific attributes.
    ///
    /// - Parameters:
    ///   - path: The file path.
    ///   - attributes: The attributes to set.
    /// - Returns: True on success, false on failure.
    @inlinable
    @discardableResult
    public static func setAttributes(
        path: UnsafePointer<WCHAR>,
        attributes: Attributes
    ) -> Bool {
        SetFileAttributesW(path, attributes.rawValue)
    }

    /// Sets file attributes by path with error throwing.
    ///
    /// - Parameters:
    ///   - path: The file path.
    ///   - attributes: The attributes to set.
    /// - Throws: `Windows.Kernel.File.Attributes.Error` on failure.
    public static func setAttributes(
        path: UnsafePointer<WCHAR>,
        to attributes: Attributes
    ) throws(Windows.Kernel.File.Attributes.Error) {
        guard SetFileAttributesW(path, attributes.rawValue) else {
            throw .platform(Error_Primitives.Error(code: Error_Primitives.Error.captureLastError()))
        }
    }

    /// Sets the read-only attribute on a file.
    ///
    /// - Parameters:
    ///   - path: The file path.
    ///   - readOnly: Whether to make the file read-only.
    /// - Returns: True on success, false on failure.
    public static func setReadOnly(
        path: UnsafePointer<WCHAR>,
        _ readOnly: Bool
    ) -> Bool {
        let current = GetFileAttributesW(path)
        guard current != INVALID_FILE_ATTRIBUTES else {
            return false
        }

        var newAttributes = current
        if readOnly {
            newAttributes |= DWORD(FILE_ATTRIBUTE_READONLY)
        } else {
            newAttributes &= ~DWORD(FILE_ATTRIBUTE_READONLY)
        }

        return SetFileAttributesW(path, newAttributes)
    }

    /// Sets the hidden attribute on a file.
    ///
    /// - Parameters:
    ///   - path: The file path.
    ///   - hidden: Whether to make the file hidden.
    /// - Returns: True on success, false on failure.
    public static func setHidden(
        path: UnsafePointer<WCHAR>,
        _ hidden: Bool
    ) -> Bool {
        let current = GetFileAttributesW(path)
        guard current != INVALID_FILE_ATTRIBUTES else {
            return false
        }

        var newAttributes = current
        if hidden {
            newAttributes |= DWORD(FILE_ATTRIBUTE_HIDDEN)
        } else {
            newAttributes &= ~DWORD(FILE_ATTRIBUTE_HIDDEN)
        }

        return SetFileAttributesW(path, newAttributes)
    }
}

// MARK: - Get Attributes

extension Windows.Kernel.File {
    /// Gets file attributes by path.
    ///
    /// - Parameter path: The file path.
    /// - Returns: The file attributes, or nil if the file doesn't exist.
    public static func getAttributes(
        path: UnsafePointer<WCHAR>
    ) -> Attributes? {
        let result = GetFileAttributesW(path)
        guard result != INVALID_FILE_ATTRIBUTES else {
            return nil
        }
        return Attributes(rawValue: result)
    }
}

#endif
