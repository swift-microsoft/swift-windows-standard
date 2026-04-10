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
import WinSDK
import Testing

@testable import Windows_Kernel_Standard
import Kernel_Primitives_Core
import Kernel_Descriptor_Primitives
import Kernel_Error_Primitives
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Kernel_IO_Primitives
import Kernel_Thread_Primitives
import Kernel_Clock_Primitives
import Kernel_Time_Primitives
import Kernel_Random_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_System_Primitives

extension Windows.Kernel.Symlink {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Symlink.Test.Unit {
    @Test("Symlink namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Symlink.self
    }
}

// MARK: - Error Mapping Tests

extension Windows.Kernel.Symlink.Test.Unit {
    @Test("Error.notFound maps from FILE_NOT_FOUND")
    func errorNotFoundFromFileNotFound() {
        let error = Kernel.Symlink.Error.current(from: Windows.Kernel.Error.Code.File.notFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test("Error.permission maps from ACCESS_DENIED")
    func errorPermissionMaps() {
        let error = Kernel.Symlink.Error.current(from: Windows.Kernel.Error.Code.Access.denied)
        if case .permission = error {
            // Expected
        } else {
            Issue.record("Expected .permission, got \(error)")
        }
    }

    @Test("Error.exists maps from FILE_EXISTS")
    func errorExistsFromFileExists() {
        let error = Kernel.Symlink.Error.current(from: Windows.Kernel.Error.Code.File.exists)
        if case .exists = error {
            // Expected
        } else {
            Issue.record("Expected .exists, got \(error)")
        }
    }

    @Test("Error.noSpace maps from DISK_FULL")
    func errorNoSpaceMaps() {
        let error = Kernel.Symlink.Error.current(from: Windows.Kernel.Error.Code.Storage.diskFull)
        if case .noSpace = error {
            // Expected
        } else {
            Issue.record("Expected .noSpace, got \(error)")
        }
    }

    @Test("Error.bufferTooSmall exists")
    func errorBufferTooSmallExists() {
        let error = Kernel.Symlink.Error.bufferTooSmall
        if case .bufferTooSmall = error {
            // Expected
        } else {
            Issue.record("Expected .bufferTooSmall, got \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Symlink.Test.EdgeCase {
    @Test("symlink may require privileges")
    func symlinkMayRequirePrivileges() {
        // Symlinks on Windows typically require:
        // - Administrator privileges, or
        // - Developer Mode enabled
        // This test just verifies the function exists and throws expected errors

        let targetPath = "C:\\target_\(GetCurrentProcessId())"
        let linkPath = "C:\\symlink_\(GetCurrentProcessId())"

        var target = Array(targetPath.utf16) + [0]
        var link = Array(linkPath.utf16) + [0]

        // Should throw (either permission or notFound)
        #expect(throws: Kernel.Symlink.Error.self) {
            try target.withUnsafeBufferPointer { targetPtr in
                try link.withUnsafeBufferPointer { linkPtr in
                    let wtarget = UnsafeRawPointer(targetPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                    let wlink = UnsafeRawPointer(linkPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                    try Windows.Kernel.Symlink.symlink(target: wtarget, link: wlink)
                }
            }
        }
    }
}

#endif
