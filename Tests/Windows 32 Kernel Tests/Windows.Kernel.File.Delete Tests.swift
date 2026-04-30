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

@testable import Windows_32_Kernel
import Error_Primitives
import Path_Primitives

extension Windows.`32`.Kernel.Unlink {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.`32`.Kernel.Unlink.Test.Unit {
    @Test
    func `Unlink namespace exists`() {
        _ = Windows.`32`.Kernel.Unlink.self
    }
}

// MARK: - Error Mapping Tests

extension Windows.`32`.Kernel.Unlink.Test.Unit {
    @Test
    func `Error.notFound maps from FILE_NOT_FOUND`() {
        let error = Kernel.Unlink.Error.current(from: Error_Primitives.Error.Code.File.notFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test
    func `Error.notFound maps from PATH_NOT_FOUND`() {
        let error = Kernel.Unlink.Error.current(from: Error_Primitives.Error.Code.File.pathNotFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test
    func `Error.permission maps from ACCESS_DENIED`() {
        let error = Kernel.Unlink.Error.current(from: Error_Primitives.Error.Code.Access.denied)
        if case .permission = error {
            // Expected
        } else {
            Issue.record("Expected .permission, got \(error)")
        }
    }

    @Test
    func `Error.busy maps from SHARING_VIOLATION`() {
        let error = Kernel.Unlink.Error.current(from: Error_Primitives.Error.Code.Access.sharingViolation)
        if case .busy = error {
            // Expected
        } else {
            Issue.record("Expected .busy, got \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.`32`.Kernel.Unlink.Test.EdgeCase {
    @Test
    func `unlink nonexistent file throws notFound`() {
        let filePath = "C:\\nonexistent_file_\(GetCurrentProcessId()).tmp"
        var path = Array(filePath.utf16) + [0]

        #expect(throws: Kernel.Unlink.Error.self) {
            try path.withUnsafeBufferPointer { pathPtr in
                let wpath = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                try Windows.`32`.Kernel.Unlink.unlink(unsafePath: wpath)
            }
        }
    }
}

#endif
