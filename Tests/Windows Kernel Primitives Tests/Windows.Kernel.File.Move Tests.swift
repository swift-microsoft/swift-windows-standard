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
import Test_Primitives
import Testing_Extras

@testable import Windows_Kernel_Primitives
import Kernel_Primitives

extension Windows.Kernel.Rename {
    #TestSuites
}

// MARK: - Namespace Tests

extension Windows.Kernel.Rename.Test.Unit {
    @Test("Rename namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Rename.self
    }
}

// MARK: - Error Mapping Tests

extension Windows.Kernel.Rename.Test.Unit {
    @Test("Error.notFound maps from FILE_NOT_FOUND")
    func errorNotFoundFromFileNotFound() {
        let error = Kernel.Rename.Error.current(from: Windows.Kernel.Error.Code.File.notFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test("Error.notFound maps from PATH_NOT_FOUND")
    func errorNotFoundFromPathNotFound() {
        let error = Kernel.Rename.Error.current(from: Windows.Kernel.Error.Code.File.pathNotFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test("Error.permission maps from ACCESS_DENIED")
    func errorPermissionMaps() {
        let error = Kernel.Rename.Error.current(from: Windows.Kernel.Error.Code.Access.denied)
        if case .permission = error {
            // Expected
        } else {
            Issue.record("Expected .permission, got \(error)")
        }
    }

    @Test("Error.exists maps from FILE_EXISTS")
    func errorExistsFromFileExists() {
        let error = Kernel.Rename.Error.current(from: Windows.Kernel.Error.Code.File.exists)
        if case .exists = error {
            // Expected
        } else {
            Issue.record("Expected .exists, got \(error)")
        }
    }

    @Test("Error.busy maps from SHARING_VIOLATION")
    func errorBusyMaps() {
        let error = Kernel.Rename.Error.current(from: Windows.Kernel.Error.Code.Access.sharingViolation)
        if case .busy = error {
            // Expected
        } else {
            Issue.record("Expected .busy, got \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Rename.Test.EdgeCase {
    @Test("rename nonexistent file throws notFound")
    func renameNonexistentThrows() {
        let oldPath = "C:\\nonexistent_rename_\(GetCurrentProcessId()).tmp"
        let newPath = "C:\\renamed_\(GetCurrentProcessId()).tmp"

        var old = Array(oldPath.utf16) + [0]
        var new = Array(newPath.utf16) + [0]

        #expect(throws: Kernel.Rename.Error.self) {
            try old.withUnsafeBufferPointer { oldPtr in
                try new.withUnsafeBufferPointer { newPtr in
                    let wold = UnsafeRawPointer(oldPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                    let wnew = UnsafeRawPointer(newPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                    try Windows.Kernel.Rename.rename(from: wold, to: wnew)
                }
            }
        }
    }
}

#endif
