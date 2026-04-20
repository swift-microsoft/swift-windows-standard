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

@testable import Windows_Kernel_Standard
import Kernel_Primitives_Core
import Kernel_Error_Primitives

extension Kernel.Error.Code {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

// MARK: - Predicate Unit Tests (Windows)

extension Kernel.Error.Code.Test.Unit {
    @Test("isNotFound matches ERROR_FILE_NOT_FOUND and ERROR_PATH_NOT_FOUND")
    func predicateIsNotFound() {
        #expect(Kernel.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isNotFound)
        #expect(Kernel.Error.Code.Windows.ERROR_PATH_NOT_FOUND.isNotFound)
        #expect(!Kernel.Error.Code.Windows.ERROR_ACCESS_DENIED.isNotFound)
    }

    @Test("isPermissionDenied matches ERROR_ACCESS_DENIED")
    func predicateIsPermissionDenied() {
        #expect(Kernel.Error.Code.Windows.ERROR_ACCESS_DENIED.isPermissionDenied)
        #expect(!Kernel.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isPermissionDenied)
    }

    @Test("isAccessDenied trampolines to isPermissionDenied")
    func predicateIsAccessDenied() {
        #expect(Kernel.Error.Code.Windows.ERROR_ACCESS_DENIED.isAccessDenied)
        #expect(!Kernel.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isAccessDenied)
    }

    @Test("isReadOnly matches ERROR_WRITE_PROTECT")
    func predicateIsReadOnly() {
        #expect(Kernel.Error.Code.Windows.ERROR_WRITE_PROTECT.isReadOnly)
        #expect(!Kernel.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isReadOnly)
    }

    @Test("isNoSpace matches ERROR_DISK_FULL")
    func predicateIsNoSpace() {
        #expect(Kernel.Error.Code.Windows.ERROR_DISK_FULL.isNoSpace)
        #expect(!Kernel.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isNoSpace)
    }

    @Test("isNotDirectory matches ERROR_DIRECTORY")
    func predicateIsNotDirectory() {
        #expect(Kernel.Error.Code.Windows.ERROR_DIRECTORY.isNotDirectory)
        #expect(!Kernel.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isNotDirectory)
    }

    @Test("isInvalidPath matches ERROR_INVALID_NAME, ERROR_BAD_PATHNAME, ERROR_INVALID_DRIVE")
    func predicateIsInvalidPath() {
        #expect(Kernel.Error.Code.Windows.ERROR_INVALID_NAME.isInvalidPath)
        #expect(Kernel.Error.Code.Windows.ERROR_BAD_PATHNAME.isInvalidPath)
        #expect(Kernel.Error.Code.Windows.ERROR_INVALID_DRIVE.isInvalidPath)
        #expect(!Kernel.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isInvalidPath)
    }

    @Test("isNetworkNotFound matches ERROR_BAD_NETPATH and ERROR_BAD_NET_NAME")
    func predicateIsNetworkNotFound() {
        #expect(Kernel.Error.Code.Windows.ERROR_BAD_NETPATH.isNetworkNotFound)
        #expect(Kernel.Error.Code.Windows.ERROR_BAD_NET_NAME.isNetworkNotFound)
        #expect(!Kernel.Error.Code.Windows.ERROR_FILE_NOT_FOUND.isNetworkNotFound)
    }
}

#endif
