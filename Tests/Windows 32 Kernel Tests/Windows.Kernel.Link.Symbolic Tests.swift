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
import Clock_Primitives
import Random_Primitives
import System_Primitives

extension Windows.`32`.Kernel.Link.Symbolic {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.`32`.Kernel.Link.Symbolic.Test.Unit {
    @Test
    func `Symlink namespace exists`() {
        _ = Windows.`32`.Kernel.Link.Symbolic.self
    }
}

// MARK: - Error Mapping Tests

extension Windows.`32`.Kernel.Link.Symbolic.Test.Unit {
    @Test
    func `Error.notFound maps from FILE_NOT_FOUND`() {
        let error = Kernel.Link.Symbolic.Error.current(from: Error_Primitives.Error.Code.File.notFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test
    func `Error.permission maps from ACCESS_DENIED`() {
        let error = Kernel.Link.Symbolic.Error.current(from: Error_Primitives.Error.Code.Access.denied)
        if case .permission = error {
            // Expected
        } else {
            Issue.record("Expected .permission, got \(error)")
        }
    }

    @Test
    func `Error.exists maps from FILE_EXISTS`() {
        let error = Kernel.Link.Symbolic.Error.current(from: Error_Primitives.Error.Code.File.exists)
        if case .exists = error {
            // Expected
        } else {
            Issue.record("Expected .exists, got \(error)")
        }
    }

    @Test
    func `Error.noSpace maps from DISK_FULL`() {
        let error = Kernel.Link.Symbolic.Error.current(from: Error_Primitives.Error.Code.Storage.diskFull)
        if case .noSpace = error {
            // Expected
        } else {
            Issue.record("Expected .noSpace, got \(error)")
        }
    }

    @Test
    func `Error.bufferTooSmall exists`() {
        let error = Kernel.Link.Symbolic.Error.bufferTooSmall
        if case .bufferTooSmall = error {
            // Expected
        } else {
            Issue.record("Expected .bufferTooSmall, got \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.`32`.Kernel.Link.Symbolic.Test.EdgeCase {
    @Test
    func `symlink creation succeeds or throws a Symbolic error`() throws {
        // Symlinks on Windows require Administrator privileges or Developer
        // Mode. CI runners typically have one of them (creation of a
        // dangling symlink then SUCCEEDS); local runs may not. Both
        // outcomes pass — only a non-Symbolic error fails the test.

        let targetPath = "C:\\target_\(GetCurrentProcessId())"
        let linkPath = "C:\\symlink_\(GetCurrentProcessId())"

        var target = Array(targetPath.utf16) + [0]
        var link = Array(linkPath.utf16) + [0]

        do {
            try target.withUnsafeBufferPointer { targetPtr in
                try link.withUnsafeBufferPointer { linkPtr in
                    let wtarget = UnsafeRawPointer(targetPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                    let wlink = UnsafeRawPointer(linkPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                    try Windows.`32`.Kernel.Link.Symbolic.create(target: wtarget, linkPath: wlink)
                }
            }
            // Privileged runner: clean up the dangling link.
            link.withUnsafeBufferPointer { linkPtr in
                let wlink = UnsafeRawPointer(linkPtr.baseAddress!).assumingMemoryBound(to: Path.Char.self)
                try? Windows.`32`.Kernel.File.Delete.delete(unsafePath: wlink)
            }
        } catch is Kernel.Link.Symbolic.Error {
            // Unprivileged runner: expected.
        }
    }
}

#endif
