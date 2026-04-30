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
import Error_Primitives
import Kernel_File_Primitives
import Path_Primitives
import Kernel_IO_Primitives
import Kernel_Thread_Primitives
import Clock_Primitives
import Random_Primitives
import Kernel_Environment_Primitives
import System_Primitives

extension Windows.Kernel.Rmdir {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Rmdir.Test.Unit {
    @Test
    func `Rmdir namespace exists`() {
        _ = Windows.Kernel.Rmdir.self
    }
}

// MARK: - Error Mapping Tests

extension Windows.Kernel.Rmdir.Test.Unit {
    @Test
    func `Error.notFound maps from FILE_NOT_FOUND`() {
        let error = Kernel.Rmdir.Error.current(from: Error_Primitives.Error.Code.File.notFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test
    func `Error.notFound maps from PATH_NOT_FOUND`() {
        let error = Kernel.Rmdir.Error.current(from: Error_Primitives.Error.Code.File.pathNotFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test
    func `Error.permission maps from ACCESS_DENIED`() {
        let error = Kernel.Rmdir.Error.current(from: Error_Primitives.Error.Code.Access.denied)
        if case .permission = error {
            // Expected
        } else {
            Issue.record("Expected .permission, got \(error)")
        }
    }

    @Test
    func `Error.notEmpty maps from DIR_NOT_EMPTY`() {
        let error = Kernel.Rmdir.Error.current(from: Error_Primitives.Error.Code.Directory.notEmpty)
        if case .notEmpty = error {
            // Expected
        } else {
            Issue.record("Expected .notEmpty, got \(error)")
        }
    }

    @Test
    func `Error.busy maps from SHARING_VIOLATION`() {
        let error = Kernel.Rmdir.Error.current(from: Error_Primitives.Error.Code.Access.sharingViolation)
        if case .busy = error {
            // Expected
        } else {
            Issue.record("Expected .busy, got \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Rmdir.Test.EdgeCase {
    @Test
    func `rmdir on nonexistent path throws notFound`() {
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
