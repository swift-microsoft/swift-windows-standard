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
    @Test("Mkdir namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Mkdir.self
    }
}

// MARK: - Error Mapping Tests

extension Windows.Kernel.Mkdir.Test.Unit {
    @Test("Error.notFound maps from PATH_NOT_FOUND")
    func errorNotFoundMaps() {
        let error = Kernel.Mkdir.Error.current(from: Windows.Kernel.Error.Code.File.pathNotFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test("Error.permission maps from ACCESS_DENIED")
    func errorPermissionMaps() {
        let error = Kernel.Mkdir.Error.current(from: Windows.Kernel.Error.Code.Access.denied)
        if case .permission = error {
            // Expected
        } else {
            Issue.record("Expected .permission, got \(error)")
        }
    }

    @Test("Error.exists maps from FILE_EXISTS")
    func errorExistsFromFileExists() {
        let error = Kernel.Mkdir.Error.current(from: Windows.Kernel.Error.Code.File.exists)
        if case .exists = error {
            // Expected
        } else {
            Issue.record("Expected .exists, got \(error)")
        }
    }

    @Test("Error.exists maps from ALREADY_EXISTS")
    func errorExistsFromAlreadyExists() {
        let error = Kernel.Mkdir.Error.current(from: Windows.Kernel.Error.Code.File.alreadyExists)
        if case .exists = error {
            // Expected
        } else {
            Issue.record("Expected .exists, got \(error)")
        }
    }

    @Test("Error.noSpace maps from DISK_FULL")
    func errorNoSpaceMaps() {
        let error = Kernel.Mkdir.Error.current(from: Windows.Kernel.Error.Code.Storage.diskFull)
        if case .noSpace = error {
            // Expected
        } else {
            Issue.record("Expected .noSpace, got \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Mkdir.Test.EdgeCase {
    @Test("Permissions.directoryDefault exists")
    func permissionsDirectoryDefaultExists() {
        let perms = Kernel.File.Permissions.directoryDefault
        #expect(perms.owner.read)
        #expect(perms.owner.write)
        #expect(perms.owner.execute)
    }
}

#endif
