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

@testable import Windows_Kernel_Primitives
import Kernel_Primitives

extension Windows.Kernel.Unlink {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Unlink.Test.Unit {
    @Test("Unlink namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Unlink.self
    }
}

// MARK: - Error Mapping Tests

extension Windows.Kernel.Unlink.Test.Unit {
    @Test("Error.notFound maps from FILE_NOT_FOUND")
    func errorNotFoundFromFileNotFound() {
        let error = Kernel.Unlink.Error.current(from: Windows.Kernel.Error.Code.File.notFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test("Error.notFound maps from PATH_NOT_FOUND")
    func errorNotFoundFromPathNotFound() {
        let error = Kernel.Unlink.Error.current(from: Windows.Kernel.Error.Code.File.pathNotFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test("Error.permission maps from ACCESS_DENIED")
    func errorPermissionMaps() {
        let error = Kernel.Unlink.Error.current(from: Windows.Kernel.Error.Code.Access.denied)
        if case .permission = error {
            // Expected
        } else {
            Issue.record("Expected .permission, got \(error)")
        }
    }

    @Test("Error.busy maps from SHARING_VIOLATION")
    func errorBusyMaps() {
        let error = Kernel.Unlink.Error.current(from: Windows.Kernel.Error.Code.Access.sharingViolation)
        if case .busy = error {
            // Expected
        } else {
            Issue.record("Expected .busy, got \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Unlink.Test.EdgeCase {
    @Test("unlink nonexistent file throws notFound")
    func unlinkNonexistentThrows() {
        let filePath = "C:\\nonexistent_file_\(GetCurrentProcessId()).tmp"
        var path = Array(filePath.utf16) + [0]

        #expect(throws: Kernel.Unlink.Error.self) {
            try path.withUnsafeBufferPointer { pathPtr in
                let wpath = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                try Windows.Kernel.Unlink.unlink(unsafePath: wpath)
            }
        }
    }
}

#endif
