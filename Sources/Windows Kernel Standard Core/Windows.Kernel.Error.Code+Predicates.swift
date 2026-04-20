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

// MARK: - Platform-Neutral Semantic Predicates
//
// These accessors let consumers describe a failure condition in domain terms
// (`isNotFound`, `isPermissionDenied`, …) instead of hand-switching between
// `Kernel.Error.Code.Windows.*` and `Kernel.Error.Code.POSIX.*`. The POSIX
// bodies live in `ISO 9945.Kernel.Error.Code+Predicates.swift` in
// swift-iso-9945; each package contributes the branch that is correct for its
// platform. Consumers see a single unified API via the re-export chain exposed
// by `import Kernel`.
//
// ```swift
// if error.code.isNotFound {
//     // Handle the "not found" failure uniformly across platforms.
// }
// ```
//
// The `#if os(Windows)` guard mirrors the sibling `Windows.Kernel.Error.swift`
// file in this target. The referenced `Kernel.Error.Code.Windows` namespace is
// itself `#if os(Windows)`-scoped in `Kernel_Error_Primitives`, so the body
// can only type-check on Windows. This target has no SwiftPM platform
// condition, so the guard is required for the non-Windows elision; it is NOT
// an in-function platform switch.

#if os(Windows)

extension Kernel.Error.Code {
    /// Returns `true` if this error code indicates that a requested file or directory does not exist.
    ///
    /// Maps to `ERROR_FILE_NOT_FOUND` and `ERROR_PATH_NOT_FOUND` on Windows.
    @inlinable
    public var isNotFound: Bool {
        self == .Windows.ERROR_FILE_NOT_FOUND
            || self == .Windows.ERROR_PATH_NOT_FOUND
    }

    /// Returns `true` if this error code indicates that the caller does not have permission for the operation.
    ///
    /// Maps to `ERROR_ACCESS_DENIED` on Windows.
    @inlinable
    public var isPermissionDenied: Bool {
        self == .Windows.ERROR_ACCESS_DENIED
    }

    /// Returns `true` if this error code indicates access was denied.
    ///
    /// Semantic alias of ``isPermissionDenied`` preserved so existing consumer code
    /// using either name continues to type-check. New call sites should prefer
    /// ``isPermissionDenied``.
    @inlinable
    public var isAccessDenied: Bool {
        isPermissionDenied
    }

    /// Returns `true` if this error code indicates a write to a read-only medium.
    ///
    /// Maps to `ERROR_WRITE_PROTECT` on Windows.
    @inlinable
    public var isReadOnly: Bool {
        self == .Windows.ERROR_WRITE_PROTECT
    }

    /// Returns `true` if this error code indicates the storage device is out of space.
    ///
    /// Maps to `ERROR_DISK_FULL` on Windows.
    @inlinable
    public var isNoSpace: Bool {
        self == .Windows.ERROR_DISK_FULL
    }

    /// Returns `true` if this error code indicates a path component was expected to be a directory but was not.
    ///
    /// Maps to `ERROR_DIRECTORY` on Windows.
    @inlinable
    public var isNotDirectory: Bool {
        self == .Windows.ERROR_DIRECTORY
    }

    /// Returns `true` if this error code indicates a syntactically invalid path.
    ///
    /// Maps to `ERROR_INVALID_NAME`, `ERROR_BAD_PATHNAME`, and `ERROR_INVALID_DRIVE` on Windows.
    @inlinable
    public var isInvalidPath: Bool {
        self == .Windows.ERROR_INVALID_NAME
            || self == .Windows.ERROR_BAD_PATHNAME
            || self == .Windows.ERROR_INVALID_DRIVE
    }

    /// Returns `true` if this error code indicates a network path or name could not be resolved.
    ///
    /// Maps to `ERROR_BAD_NETPATH` and `ERROR_BAD_NET_NAME` on Windows.
    @inlinable
    public var isNetworkNotFound: Bool {
        self == .Windows.ERROR_BAD_NETPATH
            || self == .Windows.ERROR_BAD_NET_NAME
    }
}

#endif
