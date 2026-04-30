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
import Testing

@testable import Windows_32_Kernel
import Error_Primitives

extension Error_Primitives.Error.Code {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

// MARK: - Predicate Unit Tests (Windows)

extension Error_Primitives.Error.Code.Test.Unit {
    @Test
    func `isNotFound matches ERROR_FILE_NOT_FOUND and ERROR_PATH_NOT_FOUND`() {
        #expect(Error_Primitives.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isNotFound)
        #expect(Error_Primitives.Error.Code.Windows.ERROR_PATH_NOT_FOUND.isNotFound)
        #expect(!Error_Primitives.Error.Code.Windows.ERROR_ACCESS_DENIED.isNotFound)
    }

    @Test
    func `isPermissionDenied matches ERROR_ACCESS_DENIED`() {
        #expect(Error_Primitives.Error.Code.Windows.ERROR_ACCESS_DENIED.isPermissionDenied)
        #expect(!Error_Primitives.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isPermissionDenied)
    }

    @Test
    func `isAccessDenied trampolines to isPermissionDenied`() {
        #expect(Error_Primitives.Error.Code.Windows.ERROR_ACCESS_DENIED.isAccessDenied)
        #expect(!Error_Primitives.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isAccessDenied)
    }

    @Test
    func `isReadOnly matches ERROR_WRITE_PROTECT`() {
        #expect(Error_Primitives.Error.Code.Windows.ERROR_WRITE_PROTECT.isReadOnly)
        #expect(!Error_Primitives.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isReadOnly)
    }

    @Test
    func `isNoSpace matches ERROR_DISK_FULL`() {
        #expect(Error_Primitives.Error.Code.Windows.ERROR_DISK_FULL.isNoSpace)
        #expect(!Error_Primitives.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isNoSpace)
    }

    @Test
    func `isNotDirectory matches ERROR_DIRECTORY`() {
        #expect(Error_Primitives.Error.Code.Windows.ERROR_DIRECTORY.isNotDirectory)
        #expect(!Error_Primitives.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isNotDirectory)
    }

    @Test
    func `isInvalidPath matches ERROR_INVALID_NAME, ERROR_BAD_PATHNAME, ERROR_INVALID_DRIVE`() {
        #expect(Error_Primitives.Error.Code.Windows.ERROR_INVALID_NAME.isInvalidPath)
        #expect(Error_Primitives.Error.Code.Windows.ERROR_BAD_PATHNAME.isInvalidPath)
        #expect(Error_Primitives.Error.Code.Windows.ERROR_INVALID_DRIVE.isInvalidPath)
        #expect(!Error_Primitives.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isInvalidPath)
    }

    @Test
    func `isNetworkNotFound matches ERROR_BAD_NETPATH and ERROR_BAD_NET_NAME`() {
        #expect(Error_Primitives.Error.Code.Windows.ERROR_BAD_NETPATH.isNetworkNotFound)
        #expect(Error_Primitives.Error.Code.Windows.ERROR_BAD_NET_NAME.isNetworkNotFound)
        #expect(!Error_Primitives.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isNetworkNotFound)
    }
}

#endif
