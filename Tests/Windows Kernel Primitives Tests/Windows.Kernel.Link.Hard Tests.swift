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

extension Windows.Kernel.Link {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Link.Test.Unit {
    @Test("Link namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Link.self
    }
}

// MARK: - Error Mapping Tests

extension Windows.Kernel.Link.Test.Unit {
    @Test("Error.notFound maps from FILE_NOT_FOUND")
    func errorNotFoundFromFileNotFound() {
        let error = Kernel.Link.Error.current(from: Windows.Kernel.Error.Code.File.notFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test("Error.notFound maps from PATH_NOT_FOUND")
    func errorNotFoundFromPathNotFound() {
        let error = Kernel.Link.Error.current(from: Windows.Kernel.Error.Code.File.pathNotFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test("Error.permission maps from ACCESS_DENIED")
    func errorPermissionMaps() {
        let error = Kernel.Link.Error.current(from: Windows.Kernel.Error.Code.Access.denied)
        if case .permission = error {
            // Expected
        } else {
            Issue.record("Expected .permission, got \(error)")
        }
    }

    @Test("Error.exists maps from FILE_EXISTS")
    func errorExistsFromFileExists() {
        let error = Kernel.Link.Error.current(from: Windows.Kernel.Error.Code.File.exists)
        if case .exists = error {
            // Expected
        } else {
            Issue.record("Expected .exists, got \(error)")
        }
    }

    @Test("Error.noSpace maps from DISK_FULL")
    func errorNoSpaceMaps() {
        let error = Kernel.Link.Error.current(from: Windows.Kernel.Error.Code.Storage.diskFull)
        if case .noSpace = error {
            // Expected
        } else {
            Issue.record("Expected .noSpace, got \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Link.Test.EdgeCase {
    @Test("link to nonexistent source throws notFound")
    func linkNonexistentSourceThrows() {
        let sourcePath = "C:\\nonexistent_source_\(GetCurrentProcessId()).tmp"
        let linkPath = "C:\\link_\(GetCurrentProcessId()).tmp"

        var source = Array(sourcePath.utf16) + [0]
        var link = Array(linkPath.utf16) + [0]

        #expect(throws: Kernel.Link.Error.self) {
            try source.withUnsafeBufferPointer { sourcePtr in
                try link.withUnsafeBufferPointer { linkPtr in
                    let wsource = UnsafeRawPointer(sourcePtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                    let wlink = UnsafeRawPointer(linkPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                    try Windows.Kernel.Link.link(source: wsource, link: wlink)
                }
            }
        }
    }
}

#endif
