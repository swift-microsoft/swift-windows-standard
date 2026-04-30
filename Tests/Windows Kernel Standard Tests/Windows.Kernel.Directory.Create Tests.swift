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
import Error_Primitives
import Path_Primitives
import Clock_Primitives
import Random_Primitives
import System_Primitives

extension Windows.Kernel.Mkdir {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Mkdir.Test.Unit {
    @Test
    func `Mkdir namespace exists`() {
        _ = Windows.Kernel.Mkdir.self
    }
}

// MARK: - Error Mapping Tests

extension Windows.Kernel.Mkdir.Test.Unit {
    @Test
    func `Error.notFound maps from PATH_NOT_FOUND`() {
        let error = Kernel.Mkdir.Error.current(from: Error_Primitives.Error.Code.File.pathNotFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test
    func `Error.permission maps from ACCESS_DENIED`() {
        let error = Kernel.Mkdir.Error.current(from: Error_Primitives.Error.Code.Access.denied)
        if case .permission = error {
            // Expected
        } else {
            Issue.record("Expected .permission, got \(error)")
        }
    }

    @Test
    func `Error.exists maps from FILE_EXISTS`() {
        let error = Kernel.Mkdir.Error.current(from: Error_Primitives.Error.Code.File.exists)
        if case .exists = error {
            // Expected
        } else {
            Issue.record("Expected .exists, got \(error)")
        }
    }

    @Test
    func `Error.exists maps from ALREADY_EXISTS`() {
        let error = Kernel.Mkdir.Error.current(from: Error_Primitives.Error.Code.File.alreadyExists)
        if case .exists = error {
            // Expected
        } else {
            Issue.record("Expected .exists, got \(error)")
        }
    }

    @Test
    func `Error.noSpace maps from DISK_FULL`() {
        let error = Kernel.Mkdir.Error.current(from: Error_Primitives.Error.Code.Storage.diskFull)
        if case .noSpace = error {
            // Expected
        } else {
            Issue.record("Expected .noSpace, got \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Mkdir.Test.EdgeCase {
    @Test
    func `Permissions.directoryDefault exists`() {
        let perms = Kernel.File.Permissions.directoryDefault
        #expect(perms.owner.read)
        #expect(perms.owner.write)
        #expect(perms.owner.execute)
    }
}

#endif
