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

extension Windows.`32`.Kernel.File.Move {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.`32`.Kernel.File.Move.Test.Unit {
    @Test
    func `Rename namespace exists`() {
        _ = Windows.`32`.Kernel.File.Move.self
    }
}

// MARK: - Error Mapping Tests

extension Windows.`32`.Kernel.File.Move.Test.Unit {
    @Test
    func `Error.notFound maps from FILE_NOT_FOUND`() {
        let error = Kernel.File.Move.Error.current(from: Error_Primitives.Error.Code.File.notFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test
    func `Error.notFound maps from PATH_NOT_FOUND`() {
        let error = Kernel.File.Move.Error.current(from: Error_Primitives.Error.Code.File.pathNotFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test
    func `Error.permission maps from ACCESS_DENIED`() {
        let error = Kernel.File.Move.Error.current(from: Error_Primitives.Error.Code.Access.denied)
        if case .permission = error {
            // Expected
        } else {
            Issue.record("Expected .permission, got \(error)")
        }
    }

    @Test
    func `Error.exists maps from FILE_EXISTS`() {
        let error = Kernel.File.Move.Error.current(from: Error_Primitives.Error.Code.File.exists)
        if case .exists = error {
            // Expected
        } else {
            Issue.record("Expected .exists, got \(error)")
        }
    }

    @Test
    func `Error.busy maps from SHARING_VIOLATION`() {
        let error = Kernel.File.Move.Error.current(from: Error_Primitives.Error.Code.Access.sharingViolation)
        if case .busy = error {
            // Expected
        } else {
            Issue.record("Expected .busy, got \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.`32`.Kernel.File.Move.Test.EdgeCase {
    @Test
    func `rename nonexistent file throws notFound`() {
        let oldPath = "C:\\nonexistent_rename_\(GetCurrentProcessId()).tmp"
        let newPath = "C:\\renamed_\(GetCurrentProcessId()).tmp"

        var old = Array(oldPath.utf16) + [0]
        var new = Array(newPath.utf16) + [0]

        #expect(throws: Kernel.File.Move.Error.self) {
            try old.withUnsafeBufferPointer { oldPtr in
                try new.withUnsafeBufferPointer { newPtr in
                    let wold = UnsafeRawPointer(oldPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                    let wnew = UnsafeRawPointer(newPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                    try Windows.`32`.Kernel.File.Move.move(from: wold, to: wnew)
                }
            }
        }
    }
}

#endif
