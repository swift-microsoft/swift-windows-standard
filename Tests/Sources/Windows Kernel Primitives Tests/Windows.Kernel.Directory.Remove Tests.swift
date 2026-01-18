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
import Testing

@testable import Windows_Kernel_Primitives
import Kernel_Primitives

extension Windows.Kernel.Rmdir {
    #Tests
}

// MARK: - Namespace Tests

extension Windows.Kernel.Rmdir.Test.Unit {
    @Test("Rmdir namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Rmdir.self
    }
}

// MARK: - Error Mapping Tests

extension Windows.Kernel.Rmdir.Test.Unit {
    @Test("Error.notFound maps from FILE_NOT_FOUND")
    func errorNotFoundFromFileNotFound() {
        let error = Kernel.Rmdir.Error.current(from: Windows.Kernel.Error.Code.File.notFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test("Error.notFound maps from PATH_NOT_FOUND")
    func errorNotFoundFromPathNotFound() {
        let error = Kernel.Rmdir.Error.current(from: Windows.Kernel.Error.Code.File.pathNotFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test("Error.permission maps from ACCESS_DENIED")
    func errorPermissionMaps() {
        let error = Kernel.Rmdir.Error.current(from: Windows.Kernel.Error.Code.Access.denied)
        if case .permission = error {
            // Expected
        } else {
            Issue.record("Expected .permission, got \(error)")
        }
    }

    @Test("Error.notEmpty maps from DIR_NOT_EMPTY")
    func errorNotEmptyMaps() {
        let error = Kernel.Rmdir.Error.current(from: Windows.Kernel.Error.Code.Directory.notEmpty)
        if case .notEmpty = error {
            // Expected
        } else {
            Issue.record("Expected .notEmpty, got \(error)")
        }
    }

    @Test("Error.busy maps from SHARING_VIOLATION")
    func errorBusyMaps() {
        let error = Kernel.Rmdir.Error.current(from: Windows.Kernel.Error.Code.Access.sharingViolation)
        if case .busy = error {
            // Expected
        } else {
            Issue.record("Expected .busy, got \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Rmdir.Test.EdgeCase {
    @Test("rmdir on nonexistent path throws notFound")
    func rmdirNonexistentThrows() {
        let fakePath = "C:\\nonexistent_dir_12345_\(GetCurrentProcessId())"
        var utf16Path = Array(fakePath.utf16) + [0]

        #expect(throws: Kernel.Rmdir.Error.self) {
            try utf16Path.withUnsafeBufferPointer { pathPtr in
                let ptr = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                try Windows.Kernel.Rmdir.rmdir(unsafePath: ptr)
            }
        }
    }
}

#endif
